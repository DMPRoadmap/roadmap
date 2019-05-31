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
#  name                   :string
#  org_type               :integer          default(0), not null
#  sort_name              :string
#  target_url             :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :integer
#  region_id              :integer
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (region_id => regions.id)
#

class Org < ActiveRecord::Base

  include ValidationMessages
  include ValidationValues
  include FeedbacksHelper
  include GlobalHelpers
  include FlagShihTzu
  extend Dragonfly::Model::Validations
  validates_with OrgLinksValidator

  LOGO_FORMATS = %w[jpeg png gif jpg bmp].freeze

  # Stores links as an JSON object:
  #  { org: [{"link":"www.example.com","text":"foo"}, ...] }
  # The links are validated against custom validator allocated at
  # validators/template_links_validator.rb
  serialize :links, JSON


  # ================
  # = Associations =
  # ================

  belongs_to :language

  belongs_to :region

  has_many :guidance_groups, dependent: :destroy

  has_many :templates

  has_many :users

  has_many :annotations

  has_and_belongs_to_many :token_permission_types,
                          join_table: "org_token_permissions",
                          unique: true

  has_many :org_identifiers

  has_many :identifier_schemes, through: :org_identifiers

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

  validates_property :format, of: :logo, in: LOGO_FORMATS,
                     message: _("must be one of the following formats: " +
                                "jpeg, jpg, png, gif, bmp")

  validates_size_of :logo,
                    maximum: 500.kilobytes,
                    message: _("can't be larger than 500KB")

  # allow validations for logo upload
  dragonfly_accessor :logo do
    after_assign :resize_image
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

  # Predefined queries for retrieving the managain organisation and funders
  scope :managing_orgs, -> do
    where(abbreviation: Branding.fetch(:organisation, :abbreviation))
  end

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    where("lower(orgs.name) LIKE lower(?) OR " +
          "lower(orgs.contact_email) LIKE lower(?)",
          search_pattern, search_pattern)
  }

  # Scope used in several controllers
  scope :with_template_and_user_counts, -> {
    joins("LEFT OUTER JOIN templates ON orgs.id = templates.org_id")
      .joins("LEFT OUTER JOIN users ON orgs.id = users.org_id")
      .group("orgs.id")
      .select("orgs.*,
              count(distinct templates.family_id) as template_count,
              count(users.id) as user_count")
  }

  before_validation :set_default_feedback_email_subject
  before_validation :check_for_missing_logo_file
  after_create :create_guidance_group

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Determines the locale set for the organisation
  #
  # Returns String
  # Returns nil
  def get_locale
    if !self.language.nil?
      return self.language.abbreviation
    else
      return nil
    end
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
    ret << "Institution" if self.institution?
    ret << "Funder" if self.funder?
    ret << "Organisation" if self.organisation?
    ret << "Research Institute" if self.research_institute?
    ret << "Project" if self.project?
    ret << "School" if self.school?
    return (ret.length > 0 ? ret.join(", ") : "None")
  end

  def funder_only?
    self.org_type == Org.org_type_values_for(:funder).min
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
    if abbreviation.nil? then
      return name
    else
      return abbreviation
    end
  end

  ##
  # All published templates belonging to the organisation
  #
  # Returns ActiveRecord::Relation
  def published_templates
    return templates.where("published = ?", true)
  end

  def org_admins
    User.joins(:perms).where("users.org_id = ? AND perms.name IN (?)", self.id,
      ["grant_permissions", "modify_templates", "modify_guidance", "change_org_details"])
  end

  def plans
    plan_ids = Role.administrator
                   .where(user_id: self.users.pluck(:id), active: true)
                   .pluck(:plan_id).uniq
    Plan.includes(:template, :phases, :roles, :users)
        .where(id: plan_ids)
  end

  def grant_api!(token_permission_type)
    self.token_permission_types << token_permission_type unless
      self.token_permission_types.include? token_permission_type
  end

  private

  ##
  # checks size of logo and resizes if necessary
  #
  def resize_image
    unless logo.nil?
      if logo.height != 100
        self.logo = logo.thumb("x100")  # resize height and maintain aspect ratio
      end
    end
  end

  # If the physical logo file is no longer on disk we do not want it to prevent the
  # model from saving. This typically happens when you copy the database to another
  # environment. The orgs.logo_uid stores the path to the physical logo file that is
  # stored in the Dragonfly data store (default is: public/system/dragonfly/[env]/)
  def check_for_missing_logo_file
    if self.logo_uid.present?
      data_store_path = Dragonfly.app.datastore.root_path

      if !File.exist?("#{data_store_path}#{self.logo_uid}")
        # Attempt to locate the file by name. If it exists update the uid
        logo = Dir.glob("#{data_store_path}/**/*#{self.logo_name}")
        if !logo.empty?
          self.logo_uid = logo.first.gsub(data_store_path, "")
        else
          # Otherwise the logo is missing so clear it to prevent save failures
          self.logo = nil
        end
      end
    end
  end

  def set_default_feedback_email_subject
    if self.feedback_enabled? && !self.feedback_email_subject.present?
      self.feedback_email_subject = feedback_confirmation_default_subject
    end
  end

  # creates a dfefault Guidance Group on create on the Org
  def create_guidance_group
    GuidanceGroup.create!(
      name: abbreviation? ? self.abbreviation : self.name,
      org: self,
      optional_subset: false,
      published: false,
    )
  end

end
