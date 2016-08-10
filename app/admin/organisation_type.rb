# [+Project:+] DMPonline
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre 

ActiveAdmin.register OrganisationType do
	permit_params :organisation_id, :name
	
	 menu :priority => 4, :label => proc{I18n.t('admin.org_type')}, :parent => "Organisations management"

	index do   
        column I18n.t('admin.title'), :sortable => :name do |ggn|
            link_to ggn.name, [:admin, ggn]
        end
        column I18n.t('admin.desc'), :description do |descr|
            if !descr.description.nil? then
                descr.description.html_safe
            end
        end
        
         actions
      end
  
  
    #show organisation type details
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
	
	#organisations sidebar
 	sidebar I18n.t('admin.orgs'), :only => :show, :if => proc { organisation_type.organisations.count >= 1} do
	 	table_for organisation_type.organisations.order("name") do |org_list|
	 		column I18n.t('admin.org_title'), :sortable => :name do |ggn|
                link_to ggn.name, [:admin, ggn]
            end
        end
   end
   
	 controller do
		def permitted_params
		  params.permit!
		end
  end
  		
end
