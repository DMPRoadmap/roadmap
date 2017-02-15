# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Plan do
	permit_params :template_id, :title, :org_id, :unit_id, :guidance_group_ids, :role_ids, :funder_id, :institution_id, :grant_number,:identifier, :description, :principal_investigator, :principal_investigator_identifier, :data_contact
	
	menu :priority => 25, :label => proc{I18n.t('admin.plans')}


	index do  
		column :title
		column I18n.t('admin.org_title'), :sortable => :org_id do |org_title|
            if !org_title.organisation.nil? then
                link_to org_title.organisation.name, [:admin, org_title.organisation]
            else
                '-'
            end
        end
		column I18n.t('admin.template_title'), :sortable => :template_id do |dmptemp|
            if !dmptemp.template.nil? then
                link_to dmptemp.template.title, [:admin, dmptemp.template]
            else
                '-'
            end
        end
	    	
        actions
    end
	
	
	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
