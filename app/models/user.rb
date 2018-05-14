class User < ActiveRecord::Base
  include ConditionalUserMailer
  ##
  # Devise
  #   Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable,
         :omniauth_providers => [:shibboleth, :orcid]


  ##
  # User Notification Preferences
  serialize :prefs, Hash

  ##
  # Associations
  has_and_belongs_to_many :perms, join_table: :users_perms
  belongs_to :language
  belongs_to :org
  has_one  :pref
  has_many :answers
  has_many :notes
  has_many :exported_plans
  has_many :roles, dependent: :destroy
  has_many :plans, through: :roles do
    def filter(query)
      return self unless query.present?
      t = self.arel_table
      q = "%#{query}%"
      conditions = t[:title].matches(q)
      columns = %i(
        grant_number identifier description principal_investigator data_contact
      )
      columns = ['grant_number', 'identifier', 'description', 'principal_investigator', 'data_contact']
      columns.each {|col| conditions = conditions.or(t[col].matches(q)) }
      self.where(conditions)
    end
  end

  has_many :user_identifiers
  has_many :identifier_schemes, through: :user_identifiers
  has_and_belongs_to_many :notifications, dependent: :destroy, join_table: 'notification_acknowledgements'

  validates :email, email: true, allow_nil: true, uniqueness: {message: _("must be unique")}

  ##
  # Scopes
  default_scope { includes(:org, :perms) }

  # Retrieves all of the org_admins for the specified org
  scope :org_admins, -> (org_id) {
    joins(:perms).where("users.org_id = ? AND perms.name IN (?) AND users.active = ?", org_id,
      ['grant_permissions', 'modify_templates', 'modify_guidance', 'change_org_details'], true)
  }

  scope :search, -> (term) {
    search_pattern = "%#{term}%"
    # MySQL does not support standard string concatenation and since concat_ws or concat functions do
    # not exist for sqlite, we have to come up with this conditional
    if ActiveRecord::Base.connection.adapter_name == "Mysql2"
      where("concat_ws(' ', firstname, surname) LIKE ? OR email LIKE ?", search_pattern, search_pattern)
    else
      where("firstname || ' ' || surname LIKE ? OR email LIKE ?", search_pattern, search_pattern)
    end
  }

  after_update :when_org_changes

  ##
  # This method uses Devise's built-in handling for inactive users
  def active_for_authentication?
    super && self.active?
  end

  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?

  # Determines the locale set for the user or the organisation he/she belongs
  # @return String or nil
  def get_locale
    if !self.language.nil?
      return self.language.abbreviation
    elsif !self.org.nil?
      return self.org.get_locale
    else
      return nil
    end
  end


  ##
  # gives either the name of the user, or the email if name unspecified
  #
  # @param user_email [Boolean] defaults to true, allows the use of email if there is no firstname or surname
  # @return [String] the email or the firstname and surname of the user
  def name(use_email = true)
    if (firstname.blank? && surname.blank?) || use_email then
      return email
    else
      name = "#{firstname} #{surname}"
      return name.strip
    end
  end

  ##
  # returns all active plans for a user
  #
  # @return [Plans]
  def active_plans
    self.plans.includes(:template).where("roles.active": true).where(Role.not_reviewer_condition)
  end


  ##
  # Returns the user's identifier for the specified scheme name
  #
  # @param the identifier scheme name (e.g. ORCID)
  # @return [UserIdentifier] the user's identifier for that scheme
  def identifier_for(scheme)
    user_identifiers.where(identifier_scheme: scheme).first
  end

  ##
  # sets a new organisation for the user
  #
  # @param new_organisation [Organisation] the new organisation for the user
  def organisation=(new_org)
    org_id = new_org.id unless new_org.nil?
  end

  ##
  # checks if the user is a super admin
  # if the user has any privelege which requires them to see the super admin page
  # then they are a super admin
  #
  # @return [Boolean] true if the user is an admin
  def can_super_admin?
    return self.can_add_orgs? || self.can_grant_api_to_orgs? || self.can_change_org?
  end

  ##
  # checks if the user is an organisation admin
  # if the user has any privlege which requires them to see the org-admin pages
  # then they are an org admin
  #
  # @return [Boolean] true if the user is an organisation admin
  def can_org_admin?
    return self.can_grant_permissions? || self.can_modify_guidance? ||
           self.can_modify_templates? || self.can_modify_org_details?
  end

  ##
  # checks if the user can add new organisations
  #
  # @return [Boolean] true if the user can add new organisations
  def can_add_orgs?
    perms.include? Perm.add_orgs
  end

  ##
  # checks if the user can change their organisation affiliations
  #
  # @return [Boolean] true if the user can change their organisation affiliations
  def can_change_org?
    perms.include? Perm.change_affiliation
  end

  ##
  # checks if the user can grant their permissions to others
  #
  # @return [Boolean] true if the user can grant their permissions to others
  def can_grant_permissions?
    perms.include? Perm.grant_permissions
  end

  ##
  # checks if the user can modify organisation templates
  #
  # @return [Boolean] true if the user can modify organisation templates
  def can_modify_templates?
    self.perms.include? Perm.modify_templates
  end

  ##
  # checks if the user can modify organisation guidance
  #
  # @return [Boolean] true if the user can modify organistion guidance
  def can_modify_guidance?
    perms.include? Perm.modify_guidance
  end

  ##
  # checks if the user can use the api
  #
  # @return [Boolean] true if the user can use the api
  def can_use_api?
    perms.include? Perm.use_api
  end

  ##
  # checks if the user can modify their org's details
  #
  # @return [Boolean] true if the user can modify the org's details
  def can_modify_org_details?
    perms.include? Perm.change_org_details
  end


  ##
  # checks if the user can grant the api to organisations
  #
  # @return [Boolean] true if the user can grant api permissions to organisations
  def can_grant_api_to_orgs?
    perms.include? Perm.grant_api
  end

  ##
  # removes the api_token from the user
  # modifies the user model
  def remove_token!
    unless api_token.blank?
      update_column(:api_token, "") unless new_record?
    end
  end

  ##
  # generates a new token for the user unless the user already has a token.
  # modifies the user's model.
  def keep_or_generate_token!
    if api_token.nil? || api_token.empty?
      self.api_token = loop do
        random_token = SecureRandom.urlsafe_base64(nil, false)
        break random_token unless User.exists?(api_token: random_token)
      end
      update_column(:api_token, api_token)  unless new_record?
    end
  end

  ##
  # Load the user based on the scheme and id provided by the Omniauth call
  # --------------------------------------------------------------
  def self.from_omniauth(auth)
    scheme = IdentifierScheme.find_by(name: auth.provider.downcase)

    if scheme.nil?
      throw Exception.new('Unknown OAuth provider: ' + auth.provider)
    else
      joins(:user_identifiers).where('user_identifiers.identifier': auth.uid,
                   'user_identifiers.identifier_scheme_id': scheme.id).first
    end
  end

  ##
  # Return the user's preferences for a given base key
  #
  # @return [JSON] with symbols as keys
  def get_preferences(key)
    defaults = Pref.default_settings[key.to_sym] || Pref.default_settings[key.to_s]

    if self.pref.present?
      existing = self.pref.settings[key.to_s].deep_symbolize_keys

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

  ##
  # Override devise_invitable email title
  # --------------------------------------------------------------
  def deliver_invitation(options = {})
    super(options.merge(subject: _('A Data Management Plan in %{application_name} has been shared with you') % {application_name: Rails.configuration.branding[:application][:name]}))
  end
  ##
  # Case insensitive search over User model
  # @param field [string] The name of the field being queried
  # @param val [string] The string to search for, case insensitive. val is duck typed to check whether or not downcase method exist
  # @return [ActiveRecord::Relation] The result of the search
  def self.where_case_insensitive(field, val)
    User.where("lower(#{field}) = ?", val.respond_to?(:downcase) ? val.downcase : val.to_s)
  end

  # Acknoledge a Notification
  # @param notification Notification to acknowledge
  def acknowledge(notification)
    notifications << notification if notification.dismissable?
  end

  private
  def when_org_changes
    if org_id != org_id_was
      unless can_change_org?
        perms.delete_all
        remove_token!
      end
    end
  end
end
