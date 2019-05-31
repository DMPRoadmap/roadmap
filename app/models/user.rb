# frozen_string_literal: true
# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  accept_terms           :boolean
#  active                 :boolean          default(TRUE)
#  api_token              :string
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string(80)       default(""), not null
#  encrypted_password     :string           default("")
#  firstname              :string
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  other_organisation     :string
#  recovery_email         :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0)
#  surname                :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  department_id          :integer
#  invited_by_id          :integer
#  language_id            :integer
#  org_id                 :integer
#
# Indexes
#
#  index_users_on_email   (email) UNIQUE
#  index_users_on_org_id  (org_id)
#
# Foreign Keys
#
#  fk_rails_...  (department_id => departments.id)
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (org_id => orgs.id)
#

class User < ActiveRecord::Base

  include ConditionalUserMailer
  include ValidationMessages
  include ValidationValues

  ##
  # Devise
  #   Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable,
         omniauth_providers: [:shibboleth, :orcid]


  ##
  # User Notification Preferences
  serialize :prefs, Hash

  # ================
  # = Associations =
  # ================


  has_and_belongs_to_many :perms, join_table: :users_perms

  belongs_to :language

  belongs_to :org
  
  belongs_to :department, required: false

  has_one  :pref

  has_many :answers

  has_many :notes

  has_many :exported_plans

  has_many :roles, dependent: :destroy

  has_many :plans, through: :roles


  has_many :user_identifiers

  has_many :identifier_schemes, through: :user_identifiers

  has_and_belongs_to_many :notifications, dependent: :destroy,
                          join_table: "notification_acknowledgements"


  # ===============
  # = Validations =
  # ===============

  validates :active, inclusion: { in: BOOLEAN_VALUES, message: INCLUSION_MESSAGE }

  validates :firstname, presence: { message: PRESENCE_MESSAGE }

  validates :surname, presence: { message: PRESENCE_MESSAGE }

  validates :org, presence: { message: PRESENCE_MESSAGE }

  # ==========
  # = Scopes =
  # ==========

  default_scope { includes(:org, :perms) }

  # Retrieves all of the org_admins for the specified org
  scope :org_admins, -> (org_id) {
    joins(:perms).where("users.org_id = ? AND perms.name IN (?) AND " +
                        "users.active = ?",
                        org_id,
                        ["grant_permissions",
                         "modify_templates",
                         "modify_guidance",
                         "change_org_details"],
                         true)
  }

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    # MySQL does not support standard string concatenation and since concat_ws
    # or concat functions do not exist for sqlite, we have to come up with this
    # conditional
    if ActiveRecord::Base.connection.adapter_name == "Mysql2"
      where("lower(concat_ws(' ', firstname, surname)) LIKE lower(?) OR " +
            "lower(email) LIKE lower(?)",
            search_pattern, search_pattern)
    else
      where("lower(firstname || ' ' || surname) LIKE lower(?) OR " +
            "email LIKE lower(?)", search_pattern, search_pattern)
    end
  }

  # =============
  # = Callbacks =
  # =============

  before_update :clear_other_organisation, if: :org_id_changed?

  after_update :delete_perms!, if: :org_id_changed?, unless: :can_change_org?

  after_update :remove_token!, if: :org_id_changed?, unless: :can_change_org?

  # =================
  # = Class methods =
  # =================

  ##
  # Load the user based on the scheme and id provided by the Omniauth call
  def self.from_omniauth(auth)
    joins(user_identifiers: :identifier_scheme)
      .where(user_identifiers: { identifier: auth.uid },
             identifier_schemes: { name: auth.provider.downcase }).first
  end

  def self.to_csv(users)
    User::AtCsv.new(users).to_csv
  end
  # ===========================
  # = Public instance methods =
  # ===========================

  # This method uses Devise's built-in handling for inactive users
  #
  # Returns Boolean
  def active_for_authentication?
    super && active?
  end

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Determines the locale set for the user or the organisation he/she belongs
  #
  # Returns String
  # Returns nil
  def get_locale
    if !self.language.nil?
      return self.language.abbreviation
    elsif !self.org.nil?
      return self.org.get_locale
    else
      return nil
    end
  end

  # Gives either the name of the user, or the email if name unspecified
  #
  # user_email - Use the email if there is no firstname or surname (defaults: true)
  #
  # Returns String
  def name(use_email = true)
    if (firstname.blank? && surname.blank?) || use_email then
      return email
    else
      name = "#{firstname} #{surname}"
      return name.strip
    end
  end

  # The user's identifier for the specified scheme name
  #
  # scheme - The identifier scheme name (e.g. ORCID)
  #
  # Returns UserIdentifier
  def identifier_for(scheme)
    user_identifiers.where(identifier_scheme: scheme).first
  end

  # Checks if the user is a super admin. If the user has any privelege which requires
  # them to see the super admin page then they are a super admin.
  #
  # Returns Boolean
  def can_super_admin?
    return self.can_add_orgs? || self.can_grant_api_to_orgs? || self.can_change_org?
  end

  # Checks if the user is an organisation admin if the user has any privlege which
  # requires them to see the org-admin pages then they are an org admin.
  #
  # Returns Boolean
  def can_org_admin?
    return self.can_grant_permissions? || self.can_modify_guidance? ||
           self.can_modify_templates? || self.can_modify_org_details?
  end

  # Can the User add new organisations?
  #
  # Returns Boolean
  def can_add_orgs?
    perms.include? Perm.add_orgs
  end

  # Can the User change their organisation affiliations?
  #
  # Returns Boolean
  def can_change_org?
    perms.include? Perm.change_affiliation
  end

  # Can the User can grant their permissions to others?
  #
  # Returns Boolean
  def can_grant_permissions?
    perms.include? Perm.grant_permissions
  end

  # Can the User modify organisation templates?
  #
  # Returns Boolean
  def can_modify_templates?
    self.perms.include? Perm.modify_templates
  end

  # Can the User modify organisation guidance?
  #
  # Returns Boolean
  def can_modify_guidance?
    perms.include? Perm.modify_guidance
  end

  # Can the User use the API?
  #
  # Returns Boolean
  def can_use_api?
    perms.include? Perm.use_api
  end

  # Can the User modify their org's details?
  #
  # Returns Boolean
  def can_modify_org_details?
    perms.include? Perm.change_org_details
  end

  ##
  # Can the User grant the api to organisations?
  #
  # Returns Boolean
  def can_grant_api_to_orgs?
    perms.include? Perm.grant_api
  end


  ##
  # Can the user review their organisation's plans?
  #
  # Returns Boolean
  def can_review_plans?
    perms.include? Perm.review_plans
  end

  # Removes the api_token from the user
  #
  # Returns nil
  # Returns Boolean
  def remove_token!
    return if new_record?
    update_column(:api_token, nil)
  end

  # Generates a new token for the user unless the user already has a token.
  #
  # Returns nil
  # Returns Boolean
  def keep_or_generate_token!
    if api_token.nil? || api_token.empty?
      self.api_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(api_token: random_token)
      end
      update_column(:api_token, api_token)  unless new_record?
    end
  end

  # The User's preferences for a given base key
  #
  # Returns Hash
  def get_preferences(key)
    defaults = Pref.default_settings[key.to_sym] || Pref.default_settings[key.to_s]

    if pref.present?
      existing = pref.settings[key.to_s].deep_symbolize_keys

      # Check for new preferences
      defaults.keys.each do |grp|
        defaults[grp].keys.each do |pref, v|
          # If the group isn't present in the saved values add all of it's preferences
          existing[grp] = defaults[grp] if existing[grp].nil?
          # If the preference isn't present in the saved values add the default
          existing[grp][pref] = defaults[grp][pref] if existing[grp][pref].nil?
        end
      end
      existing
    else
      defaults
    end
  end

  # Override devise_invitable email title
  def deliver_invitation(options = {})
    super(options.merge(subject: _("A Data Management Plan in " +
      "%{application_name} has been shared with you") %
      { application_name: Rails.configuration.branding[:application][:name] })
    )
  end

  # Case insensitive search over User model
  #
  # field - The name of the field being queried
  # val   - The String to search for, case insensitive. val is duck typed to check
  #         whether or not downcase method exist.
  #
  # Returns ActiveRecord::Relation
  # Raises ArgumentError
  def self.where_case_insensitive(field, val)
    unless columns.map(&:name).include?(field.to_s)
      raise ArgumentError, "Field #{field} is not present on users table"
    end
    User.where("LOWER(#{field}) = :value", value: val.to_s.downcase)
  end

  # Acknowledge a Notification
  #
  # notification - Notification to acknowledge
  #
  # Returns ActiveRecord::Associations::CollectionProxy
  # Returns nil
  def acknowledge(notification)
    notifications << notification if notification.dismissable?
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  def delete_perms!
    perms.destroy_all
  end

  def clear_other_organisation
    self.other_organisation = nil
  end

end
