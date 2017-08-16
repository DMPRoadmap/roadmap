class User < ActiveRecord::Base
  include GlobalHelpers

  ##
  # Devise
  #   Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, 
         :rememberable, :trackable, :validatable, :omniauthable, 
         :omniauth_providers => [:shibboleth, :orcid]

  ##
  # Associations
  has_and_belongs_to_many :perms, join_table: :users_perms
  belongs_to :language
  belongs_to :org
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

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  #accepts_nested_attributes_for :roles
  #attr_accessible :password_confirmation, :encrypted_password, :remember_me, 
  #                :id, :email, :firstname, :last_login,:login_count, :orcid_id, 
  #                :password, :shibboleth_id, :user_status_id, :surname, 
  #                :user_type_id, :org_id, :skip_invitation, :other_organisation, 
  #                :accept_terms, :role_ids, :dmponline3, :api_token,
  #                :organisation, :language, :language_id, :org, :perms, 
  #                :confirmed_at, :org_id

  validates :email, email: true, allow_nil: true, uniqueness: {message: _("must be unique")}

  ##
  # Scopes
  default_scope { includes(:org, :perms) }



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
  # Returns the user's identifier for the specified scheme name
  #
  # @param the identifier scheme name (e.g. ORCID)
  # @return [UserIdentifier] the user's identifier for that scheme
  def identifier_for(scheme)
    user_identifiers.where(identifier_scheme: scheme).first
  end

# TODO: Check the logic here. Its deleting the permissions if the user does not have permission
#       to change orgs and either the incoming or existing org is nil.
#       We should also NOT be auto-saving here!!!
  ##
  # sets a new organisation id for the user
  # if the user has any perms such as org_admin or admin, those are removed
  # if the user had an api_token, that is removed
  #
  # @param new_organisation_id [Integer] the id for an organisation
  # @return [String] the empty string as a causality of setting api_token
  def org_id=(new_org_id)
    unless self.can_change_org? || new_org_id.nil? || self.org.nil? || (new_org_id.to_s == self.org.id.to_s)
      # rip all permissions from the user
      self.perms.delete_all
    end
    # set the user's new organisation
    super(new_org_id)
    self.save!
    # rip api permissions from the user
    self.remove_token!
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
  # checks what type the user's organisation is
  #
  # @return [String] the organisation type
=begin
  def org_type
    org_type = org.organisation_type
    return org_type
  end
=end
  
  ##
  # removes the api_token from the user
  # modifies the user model
  def remove_token!
    unless api_token.blank?
      self.api_token = ""
      self.save!
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
      self.save!
      # send an email to the user to notify them of their new api token
      #UserMailer.api_token_granted_notification(self)
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
  # Override devise_invitable email title
  # --------------------------------------------------------------
  def deliver_invitation(options = {})
    super(options.merge(subject: _('A Data Management Plan in %{application_name} has been shared with you') % {application_name: Rails.configuration.branding[:application][:name]}))
  end


# TODO: Remove this, its never called.
  # this generates a reset password link for a given user
  # which can then be sent to them with the appropriate host
  # prepended.
=begin
  def reset_password_link
    raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
    self.reset_password_token   = enc 
    self.reset_password_sent_at = Time.now.utc
    save(validate: false)

    edit_user_password_path  + '?reset_password_token=' + raw
  end
=end
  
end
