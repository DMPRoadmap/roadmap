class User < ActiveRecord::Base
  include GlobalHelpers
  ##
  # Devise
  #   Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :omniauthable, :omniauth_providers => [:shibboleth]

  ##
  # Associations
  has_and_belongs_to_many :perms, join_table: :users_perms
  belongs_to :language
  belongs_to :org
  has_many :answers
  has_many :notes
  has_many :roles, dependent: :destroy
  has_many :projects, through: :roles do
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

  ##
  # Possibly needed for active_admin
  #   -relies on protected_attributes gem as syntax depricated in rails 4.2
  accepts_nested_attributes_for :roles
  attr_accessible :password_confirmation, :encrypted_password, :remember_me, :id, :email,
                  :firstname, :last_login,:login_count, :orcid_id, :password, :shibboleth_id, 
                  :user_status_id, :surname, :user_type_id, :org_id, :skip_invitation, 
                  :other_organisation, :accept_terms, :role_ids, :dmponline3, :api_token,
                  :organisation, :language, :language_id

  validates :email, email: true, allow_nil: true, uniqueness: true

  ##
  # Settings
  # FIXME: The duplication in the block is to set defaults. It might be better if
  #        they could be set in Settings::PlanList itself, if possible.
  has_settings :plan_list, class_name: 'Settings::PlanList' do |s|
    s.key :plan_list, defaults: { columns: Settings::PlanList::DEFAULT_COLUMNS }
  end




  # EVALUATE CLASS AND INSTANCE METHODS BELOW
  #
  # What do they do? do they do it efficiently, and do we need them?





  ##
  # gives either the name of the user, or the email if name unspecified
  #
  # @param user_email [Boolean] defaults to true, allows the use of email if there is no firstname or surname
  # @return [String] the email or the firstname and surname of the user
  def name(use_email = true)
    if ((firstname.nil? && surname.nil?) || (firstname.strip == "" && surname.strip == "")) && use_email then
      return email
    else
      name = "#{firstname} #{surname}"
      return name.strip
    end
  end

  ##
  # sets a new organisation id for the user
  # if the user has any perms such as org_admin or admin, those are removed
  # if the user had an api_token, that is removed
  #
  # @param new_organisation_id [Integer] the id for an organisation
  # @return [String] the empty string as a causality of setting api_token
  def organisation_id=(new_organisation_id)
    unless self.can_change_org? || new_organisation_id.nil? || self.organisation.nil?
      # rip all permissions from the user
      self.perms.delete_all
    end
    # set the user's new organisation
    super(new_organisation_id)
    self.save!
    # rip api permissions from the user
    self.remove_token!
  end

  ##
  # sets a new organisation for the user
  #
  # @param new_organisation [Organisation] the new organisation for the user
  def organisation=(new_organisation)
    organisation_id = new_organisation.id unless new_organisation.nil?
  end

  ##
  # checks if the user is a super admin
  # if the user has any privelege which requires them to see the super admin page
  # then they are a super admin
  #
  # @return [Boolean] true if the user is an admin
  def can_super_admin?
    return self.can_add_orgs? || self.can_grant_api_to_orgs? || can_change_org?
  end

  ##
  # checks if the user is an organisation admin
  # if the user has any privlege which requires them to see the org-admin pages
  # then they are an org admin
  #
  # @return [Boolean] true if the user is an organisation admin
  def can_org_admin?
    return self.can_grant_permissions? || self.can_modify_guidance? || self.can_modify_templates? || self.can_modify_org_details?
  end

  ##
  # checks if the user can add new organisations
  #
  # @return [Boolean] true if the user can add new organisations
  def can_add_orgs?
    perms.include? Perm.find_by(name: constant("user_role_types.add_organisations"))
  end

  ##
  # checks if the user can change their organisation affiliations
  #
  # @return [Boolean] true if the user can change their organisation affiliations
  def can_change_org?
    perms.include? Perm.find_by(name: constant("user_role_types.change_org_affiliation"))
  end

  ##
  # checks if the user can grant their permissions to others
  #
  # @return [Boolean] true if the user can grant their permissions to others
  def can_grant_permissions?
    perms.include? Perm.find_by(name: constant("user_role_types.grant_permissions"))
  end

  ##
  # checks if the user can modify organisation templates
  #
  # @return [Boolean] true if the user can modify organisation templates
  def can_modify_templates?
    perms.include? Perm.find_by(name: constant("user_role_types.modify_templates"))
  end

  ##
  # checks if the user can modify organisation guidance
  #
  # @return [Boolean] true if the user can modify organistion guidance
  def can_modify_guidance?
    perms.include? Perm.find_by(name: constant("user_role_types.modify_guidance"))
  end

  ##
  # checks if the user can use the api
  #
  # @return [Boolean] true if the user can use the api
  def can_use_api?
    perms.include? Perm.find_by(name: constant("user_role_types.use_api"))
  end

  ##
  # checks if the user can modify their org's details
  #
  # @return [Boolean] true if the user can modify the org's details
  def can_modify_org_details?
    perms.include? Perm.find_by(name: constant("user_role_types.change_org_details"))
  end

  ##
  # checks if the user can grant the api to organisations
  #
  # @return [Boolean] true if the user can grant api permissions to organisations
  def can_grant_api_to_orgs?
    perms.include? Perm.find_by(name: constant('user_role_types.grant_api_to_orgs'))
  end


  ##
  # checks if the user can grant the api to organisations
  #
  # @return [Boolean] true if the user can grant api permissions to organisations
  def can_grant_api_to_orgs?
    perms.include? Perm.find_by(name: constant('user_role_types.grant_api_to_orgs'))
  end

  ##
  # checks what type the user's organisation is
  #
  # @return [String] the organisation type
  def org_type
    org_type = org.organisation_type
    return org_type
  end

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
      UserMailer.api_token_granted_notification(self)
    end
  end
end
