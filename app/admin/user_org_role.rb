# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register UserOrgRole do
	permit_params  :user_id, :organisation_id, :user_role_type_id
	
	menu false
	#:priority => 5, :label => proc{I18n.t('admin.user_org_role')}, :parent => "User management"

	index do  
        column I18n.t('admin.user'), :sortable => :user_id do |user_n|
            if !user_n.user.nil? then
                link_to user_n.user.firstname, [:admin, user_n.user]
            end
        end
        column I18n.t('admin.org'), :sortable => :organisation_id do |org|
            if !org.organisation.nil? then
               link_to org.organisation.name, [:admin, org.organisation]
            end	
        end
        column I18n.t('admin.user_role_type'), :sortable => :user_role_type_id do |role|
            if !role.user_role_type.nil? then
               link_to role.user_role_type.name, [:admin, role.user_role_type]
            end
        end
        
        actions
    end
  
    show do
		attributes_table do
			row I18n.t('admin.user'), :user_id do |user_n|
                link_to user_n.user.firstname, [:admin, user_n.user]
            end
            row I18n.t('admin.org'), :organisation_id do |org|
                link_to org.organisation.name, [:admin, org.organisation]
            end
            row I18n.t('admin.user_role_type'), :user_role_type_id do |role|
                link_to role.user_role_type.name, [:admin, role.user_role_type]
            end
            row :created_at
            row :updated_at
        end
    end		
	
	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
