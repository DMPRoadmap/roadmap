# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register UserType do
	permit_params :description, :name
	
	menu false
	 #:priority => 5, :label => proc{I18n.t('admin.user_type')}, :parent => "User management"

	index do   
        column I18n.t('admin.user_type'), :sortable => :name do |user_n|
            link_to user_n.name, [:admin, user_n]
        end
     	
        actions
    end
  
  # show Template details
	show do 
		attributes_table do
			row :name
			row :description do |descr|
                if !descr.description.nil? then
                    descr.description.html_safe
                end
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
