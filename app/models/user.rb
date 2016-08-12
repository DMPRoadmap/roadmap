class User < ActiveRecord::Base
  include GlobalHelpers

	rolify
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :omniauthable, :omniauth_providers => [:shibboleth]

    #associations between tables
    belongs_to :user_type
    belongs_to :user_status
    has_many :answers
    has_many :user_org_roles
    has_many :project_groups, :dependent => :destroy
    has_many :organisations , through: :user_org_roles
    has_many :user_role_types, through: :user_org_roles
		has_one :language



    has_many :projects, through: :project_groups do
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

    # Commented out due to warning in Rails 4. This line is redundant due to use of the rolify gem
    #has_and_belongs_to_many :roles, :join_table => :users_roles

    has_many :plan_sections

    accepts_nested_attributes_for :roles
    attr_accessible :password_confirmation, :encrypted_password, :remember_me, :id, :email,
                    :firstname, :last_login,:login_count, :orcid_id, :password, :shibboleth_id, 
                    :user_status_id, :surname, :user_type_id, :organisation_id, :skip_invitation, 
                    :other_organisation, :accept_terms, :role_ids, :dmponline3, :api_token,
										:language_id

    # FIXME: The duplication in the block is to set defaults. It might be better if
    #        they could be set in Settings::PlanList itself, if possible.
    has_settings :plan_list, class_name: 'Settings::PlanList' do |s|
      s.key :plan_list, defaults: { columns: Settings::PlanList::DEFAULT_COLUMNS }
    end

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
  # if the user has any roles such as org_admin or admin, those are removed
  # if the user had an api_token, that is removed
  #
  # @param new_organisation_id [Integer] the id for an organisation
  # @return [String] the empty string as a causality of setting api_token
	def organisation_id=(new_organisation_id)
        # if the user is not part of the new organisation
        if !self.user_org_roles.pluck(:organisation_id).include?(new_organisation_id.to_i) then
            # if the user has more than one role
      		if self.user_org_roles.count != 1 then
      			new_user_org_role = UserOrgRole.new
      			new_user_org_role.organisation_id = new_organisation_id
      			new_user_org_role.user_role_type = UserRoleType.find_by(name: constant("user_role_types.user"));
      			self.user_org_roles << new_user_org_role
                #
            # if the user has roles other than one(0/2/3?)
      		else
                # set role to first role
      			user_org_role = self.user_org_roles.first
                # change org_id to new org_id
      			user_org_role.organisation_id = new_organisation_id
                # save modified role
                user_org_role.save
                # if user has an "org_admin" role
      			org_admin_role = roles.find_by(name: constant("user_role_types.org_admin"))
      			unless org_admin_role.nil? then
                    # delete it
      				roles.delete(org_admin_role)
      			end
      		end
        end
        # rip api_token from user
        self.remove_token!
	end

  ##
  # returns the first organisation id of the user or nil
  #
  # @return [Integer, nil] the id of the user's organisation
	def organisation_id
		if self.organisations.count > 0 then
			return self.organisations.first.id
		else
			return nil
		end
	end

  ##
  # returns the organisation of the user or nil
  #
  # @return [Organisation, nil] the organisation of the user
	def organisation
		if self.organisations.count > 0 then
			return self.organisations.first
		else
			return nil
		end
	end

  ##
  # returns the last organisation in the list of organisations
  # possibly depricated as the user only has one organisation in the current schema
  #
  # @return [Organisation, nil] the organisation for the user
	def current_organisation
		if self.organisations.count > 0 then
			return self.organisations.last
		else
			return nil
		end
	end

  ##
  # sets a new organisation for the user
  #
  # @params new_organisation [Organisation] the new organisation for the user
	def organisation=(new_organisation)
		organisation_id = organisation.id
	end

  ##
  # checks if the user is an admin
  #
  # @return [Boolean] true if the user is an admin
	def is_admin?
		admin = roles.find_by( name: constant("user_role_types.super_admin"))
		return !admin.nil?
	end

  ##
  # checks if the user is an organisation admin
  #
  # @return [Boolean] true if the user is an organisation admin
	def is_org_admin?
		org_admin = roles.find_by(name: constant("user_role_types.organisational_admin"))
		return !org_admin.nil?
	end

  ##
  # checks what type the user's organisation is
  #
  # @return [String] the organisation type
  def org_type
    org_type = organisation.organisation_type.name
    return org_type
  end

  ##
  # removes the api_token from the user
  # modifies the user model
  def remove_token!
    unless api_token.empty?
      self.api_token = ""
      self.save!
    end
  end

  #
  # generates a new token for the user unless the user already has a token.
  # modifies the user's model.
  def keep_or_generate_token!
    if api_token.empty?
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
