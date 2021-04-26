# frozen_string_literal: true

# == Schema Information
#
# Table name: orgs
#
#  id                     :integer          not null, primary key
#  abbreviation           :string
#  contact_email          :string
#  contact_name           :string
#  feedback_email_msg     :text
#  feedback_email_subject :string
#  feedback_enabled       :boolean          default(FALSE)
#  is_other               :boolean          default(FALSE), not null
#  links                  :text
#  logo_name              :string
#  logo_uid               :string
#  managed                :boolean          default(FALSE), not null
#  name                   :string
#  org_type               :integer          default(0), not null
#  sort_name              :string
#  target_url             :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :integer
#  region_id              :integer
#  managed                :boolean          default(false), not null
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
class Org < ApplicationRecord

  extend FeedbacksHelper
  include FlagShihTzu
  include Identifiable

  extend Dragonfly::Model::Validations
  validates_with OrgLinksValidator

  LOGO_FORMATS = %w[jpeg png gif jpg bmp].freeze

  HUMANIZED_ATTRIBUTES = {
    feedback_email_msg: _("Feedback email message")
  }.freeze

  # TODO: we don't allow this to be edited on the frontend, can we remove from DB?
  # if not, we'll need to add a rake:task to ensure that each of these is set for each
  # org
  attribute :feedback_email_subject, :string, default: feedback_confirmation_default_subject
  attribute :feedback_email_msg, :text, default: feedback_confirmation_default_message
  attribute :language_id, :integer, default: -> { Language.default&.id }
  attribute :links, :text, default: { "org": [] }

  # Stores links as an JSON object:
  #  { org: [{"link":"www.example.com","text":"foo"}, ...] }
  # The links are validated against custom validator allocated at
  # validators/template_links_validator.rb
  serialize :links, JSON

  # ================
  # = Associations =
  # ================

  belongs_to :language

  belongs_to :region, optional: true

  has_one :tracker, dependent: :destroy
  accepts_nested_attributes_for :tracker
  validates_associated :tracker

  has_many :guidance_groups, dependent: :destroy

  has_many :plans

  has_many :funded_plans, class_name: "Plan", foreign_key: "funder_id"

  has_many :templates

  has_many :users

  has_many :contributors

  has_many :annotations

  has_and_belongs_to_many :token_permission_types,
                          join_table: "org_token_permissions",
                          unique: true

  has_many :departments

  # ===============
  # = Validations =
  # ===============

  validates :name, presence: { message: PRESENCE_MESSAGE },
                   uniqueness: { message: UNIQUENESS_MESSAGE }

  validates :abbreviation, presence: { message: PRESENCE_MESSAGE }

  validates :is_other, inclusion: { in: BOOLEAN_VALUES,
                                    message: INCLUSION_MESSAGE }

  validates :language, presence: { message: PRESENCE_MESSAGE }

  validates :contact_name, presence: { message: PRESENCE_MESSAGE,
                                       if: :feedback_enabled }

  validates :contact_email, email: { allow_nil: true },
                            presence: { message: PRESENCE_MESSAGE,
                                        if: :feedback_enabled }

  validates :org_type, presence: { message: PRESENCE_MESSAGE }

  validates :feedback_enabled, inclusion: { in: BOOLEAN_VALUES,
                                            message: INCLUSION_MESSAGE }

  validates :feedback_email_subject, presence: { message: PRESENCE_MESSAGE,
                                                 if: :feedback_enabled }

  validates :feedback_email_msg, presence: { message: PRESENCE_MESSAGE,
                                             if: :feedback_enabled }

  validates :managed, inclusion: { in: BOOLEAN_VALUES,
                                   message: INCLUSION_MESSAGE }

  validates_property :format, of: :logo, in: LOGO_FORMATS,
                              message: _("must be one of the following formats: " \
                                "jpeg, jpg, png, gif, bmp")

  validates_size_of :logo,
                    maximum: 500.kilobytes,
                    message: _("can't be larger than 500KB")

  # allow validations for logo upload
  dragonfly_accessor :logo do
    after_assign :resize_image
  end

  # =============
  # = Callbacks =
  # =============
  # This checks the filestore for the dragonfly image each time before we validate
  # and removes the dragonfly info if the logo is not found so validations pass
  # TODO: re-evaluate this after moving dragonfly to active_storage
  before_validation :check_for_missing_logo_file

  # If the physical logo file is no longer on disk we do not want it to prevent the
  # model from saving. This typically happens when you copy the database to another
  # environment. The orgs.logo_uid stores the path to the physical logo file that is
  # stored in the Dragonfly data store (default is: public/system/dragonfly/[env]/)
  def check_for_missing_logo_file
    return unless logo_uid.present?

    data_store_path = Dragonfly.app.datastore.root_path

    return if File.exist?("#{data_store_path}#{logo_uid}")

    # Attempt to locate the file by name. If it exists update the uid
    logo = Dir.glob("#{data_store_path}/**/*#{logo_name}")
    if !logo.empty?
      self.logo_uid = logo.first.gsub(data_store_path, "")
    else
      # Otherwise the logo is missing so clear it to prevent save failures
      self.logo = nil
    end
  end

  ##
  # Define Bit Field values
  # Column org_type
  has_flags 1 => :institution,
            2 => :funder,
            3 => :organisation,
            4 => :research_institute,
            5 => :project,
            6 => :school,
            column: "org_type"

  # The default Org is the one whose guidance is auto-attached to
  # plans when a plan is created
  def self.default_orgs
    where(abbreviation: Rails.configuration.x.organisation.abbreviation)
  end

  # The managed flag is set by a Super Admin. A managed org typically has
  # at least one Org Admini and can have associated Guidance and Templates
  scope :managed, -> { where(managed: true) }
  # An un-managed Org is one created on the fly by the system
  scope :unmanaged, -> { where(managed: false) }

  scope :search, lambda { |term|
    search_pattern = "%#{term}%"
    where("lower(orgs.name) LIKE lower(?) OR " \
          "lower(orgs.contact_email) LIKE lower(?)",
          search_pattern, search_pattern)
  }

  # Scope used in several controllers
  scope :with_template_and_user_counts, lambda {
    joins("LEFT OUTER JOIN templates ON orgs.id = templates.org_id")
      .joins("LEFT OUTER JOIN users ON orgs.id = users.org_id")
      .group("orgs.id")
      .select("orgs.*,
              count(distinct templates.family_id) as template_count,
              count(users.id) as user_count")
  }

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Update humanized attributes with HUMANIZED_ATTRIBUTES
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # ===========================
  # = Public instance methods =
  # ===========================

  # Determines the locale set for the organisation
  #
  # Returns String
  # Returns nil
  def locale
    language&.abbreviation
  end

  # TODO: Should these be hardcoded? Also, an Org can currently be multiple org_types at
  # one time. For example you can do: funder = true; project = true; school = true
  #
  # Calling type in the above scenario returns "Funder" which is a bit misleading
  # Is FlagShihTzu's Bit flag the appropriate structure here or should we use an enum?
  # Tests are setup currently to work with this issue.
  #
  # Returns String
  def org_type_to_s
    ret = []
    ret << "Institution" if institution?
    ret << "Funder" if funder?
    ret << "Organisation" if organisation?
    ret << "Research Institute" if research_institute?
    ret << "Project" if project?
    ret << "School" if school?
    (!ret.empty? ? ret.join(", ") : "None")
  end
  # rubocop:enable

  def funder_only?
    org_type == Org.org_type_values_for(:funder).min
  end

  ##
  # The name of the organisation
  #
  # Returns String
  def to_s
    name
  end

  ##
  # The abbreviation for the organisation if it exists, or the name if not
  #
  # Returns String
  def short_name
    if abbreviation.nil?
      name
    else
      abbreviation
    end
  end

  ##
  # All published templates belonging to the organisation
  #
  # Returns ActiveRecord::Relation
  def published_templates
    templates.where("published = ?", true)
  end

  def org_admins
    admin_perms = %w[grant_permissions modify_templates modify_guidance change_org_details]
    User.joins(:perms).where("users.org_id = ? AND perms.name IN (?)", id, admin_perms)
  end

  def plans
    Rails.cache.fetch("org[#{id}].plans", expires_in: 2.seconds) do
      plan_ids = Role.administrator
                     .where(user_id: users.pluck(:id), active: true)
                     .pluck(:plan_id).uniq
      Plan.includes(:template, :phases, :roles, :users)
          .where(id: plan_ids)
    end
  end

  def grant_api!(token_permission_type)
    token_permission_types << token_permission_type unless
      token_permission_types.include? token_permission_type
  end

  private

  ##
  # checks size of logo and resizes if necessary
  #
  def resize_image
    return if logo.nil? || logo.height == 100

    self.logo = logo.thumb("x100") # resize height and maintain aspect ratio
  end

end
