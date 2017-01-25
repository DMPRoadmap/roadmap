# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Role do
	permit_params :name

	menu :priority => 5, :label => proc{I18n.t('admin.role')}, :parent => "User management"

	index do   
        column I18n.t('admin.title'), :sortable => :name do |role_name|
            link_to role_name.name, [:admin, role_name]
        end

        actions
    end
      
  
    show do
		attributes_table do
			row :name
			row :created_at
			row :updated_at
		end
        
        table_for( (Role.find(params[:id]).users)) do
	 		column (:email){|user| link_to user.email, [:admin, user]} 
			column (:firstname){|user| user.firstname}
			column (:surname){|user| user.surname}
            column (:last_sign_in_at){|user| user.last_sign_in_at}
            column (I18n.t('admin.org_title')){|user|
                if !user.organisation.nil? then
                    if user.other_organisation.nil? || user.other_organisation == "" then
                        link_to user.organisation.name, [:admin, user.organisation]
                    else
                        I18n.t('helpers.org_type.org_name') + ' - ' + user.other_organisation
        	 
                    end	 
                end
            }
		end	
        
	end		
	
	form do |f|
        f.inputs "Details" do
            f.input :name
        end    
	  
        f.actions    
    end
  
	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
