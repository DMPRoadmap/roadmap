# [+Project:+] DMPRoadmap
# [+Description:+]
#
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register User do
	permit_params :api_token, :password_confirmation, :encrypted_password, :remember_me, :id, :email, :firstname, :orcid_id, :shibboleth_id, :user_status_id, :surname, :user_type_id, :organisation_id, :skip_invitation,  :other_organisation, :accept_terms, :role_ids

	menu :priority => 15, :label => proc{ I18n.t('admin.user')}, :parent => "User management"

	filter :firstname
	filter :surname
	filter :email
	filter :organisations
  filter :other_organisation
	filter :created_at
	filter :updated_at



	index do

  	column I18n.t('admin.user_name'), :sortable => :email do |user_email|
        link_to user_email.email, [:admin, user_email]
    end
    column I18n.t('admin.firstname'), :sortable => :firstname do |use_first|
        link_to use_first.firstname, [:admin, use_first]
    end
  	column I18n.t('admin.surname'), :sortable => :surname do |user|
        link_to user.surname, [:admin, user]
    end
   	column I18n.t('admin.last_logged_in'), :last_sign_in_at
   	column I18n.t('admin.org_title'), :sortable => 'organisations.name' do |org_title|
      if !org_title.organisation.nil? then
      	if org_title.other_organisation.nil? || org_title.other_organisation == "" then
      		link_to org_title.organisation.name, [:admin, org_title.organisation]
      	else
      		I18n.t('helpers.org_type.org_name') + ' - ' + org_title.other_organisation

        end
      end
   	end

  	 actions
  end

  show do
  		attributes_table do
  			row :firstname
  			row :surname
  			row :email
  			row :orcid_id
  			row I18n.t('admin.org_title'), :organisation_id do |org_title|
		      if !org_title.organisation_id.nil? then
		        link_to org_title.organisation.name, [:admin, org_title.organisation]
          end
		   	end
        row :other_organisation
  		#	row I18n.t('admin.user_status'), :user_status_id do |us|
  		#		if !us.user_status.nil? then
  		#			link_to us.user_status.name, [:admin, us.user_status]
  		#		end
  		#	end
  		#	row I18n.t('admin.user_type'), :user_type_id do |ut|
  		#		if !ut.user_type.nil? then
  		#			link_to ut.user_type.name, [:admin, ut.user_type]
  		#		else
  		#			'-'
  		#		end
  		#	end
  			row I18n.t('admin.user_role') do
  				(user.roles.map{|ro| link_to ro.name, [:admin, ro]}).join(', ').html_safe
  			end
  		#	row :shibboleth_id
  			row :last_sign_in_at
  			row :sign_in_count
        row :api_token

  		end
  end


  form do |f|
  	f.inputs "Details" do
        f.input :firstname
  			f.input :surname
  			f.input :email
  			f.input :orcid_id
        f.input :api_token
  		#	f.input :shibboleth_id
  			f.input :organisation_id ,:label => I18n.t('admin.org_title'),
  						:as => :select,
  						:collection => Organisation.order('name').map{|orgp|[orgp.name, orgp.id]}
  			f.input :other_organisation
  		#	f.input :user_status_id, :label => I18n.t('admin.user_status'),
  		#				:as => :select,
  		#				:collection => UserStatus.find(:all, :order => 'name ASC').map{|us|[us.name, us.id]}
  		#	f.input :user_type_id, :label => I18n.t('admin.user_type'),
  		#				:as => :select,
  		#				:collection => UserType.find(:all, :order => 'name ASC').map{|ut|[ut.name, ut.id]}
  			f.input :role_ids, :label => I18n.t('admin.user_role'),
  							:as => :select,
  							:multiple => true,
                            :include_blank => I18n.t('helpers.none'),
  							:collection => Role.order('name').map{|ro| [ro.name, ro.id]}

        f.input :api_token
    end

    f.actions
  end



  controller do
    def scoped_collection
      resource_class.includes(:organisations) # prevents N+1 queries to your database
    end

	def permitted_params
	  params.permit!
	end

  end

end
