# [+Project:+] DMPonline
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre 

ActiveAdmin.register Version do
	permit_params   :description, :number, :published, :title, :phase_id
	
	menu :priority => 9, :label => proc{I18n.t('admin.version')}, :parent =>  "Templates management"

	index do  
        column I18n.t('admin.title'), :sortable => :title  do |version_used|
            if !version_used.title.nil? then
                 link_to version_used.title, [:admin, version_used]
           end
        end
        column I18n.t('admin.version_numb'), :number
        column :published
        column I18n.t('admin.phase'), :sortable => :phase_id do |phase_title|
	  		if !phase_title.phase_id.nil? then
                link_to phase_title.phase.title, [:admin, phase_title.phase]
            else 
                '-'
	   		end
     	end
            
        actions
      end
  
  #show details of a version
  show do 
		attributes_table do
			row :title
	 		row	:number
	 		row :description do |descr|
	  		if !descr.description.nil? then
	  			descr.description.html_safe
	  		end
	  	end
	  	row I18n.t('admin.phase'), :sortable => :phase_id do |phase_title|
	  		if !phase_title.phase_id.nil? then
                link_to phase_title.phase.title, [:admin, phase_title.phase]	  
	   		end
     	end
     	row :published
     	row :created_at
     	row :updated_at
		 end
		 
		end 
  
  #sections sidebar  (:organisation_id, :description, :number, :title, :version_id)
 		sidebar I18n.t('admin.sections'), :only => :show, :if => proc { version.sections.count >= 1}  do
 		 	table_for version.sections.order("number") do |temp_phases|
 		 		column :number
 		 		column :title do |row|
      		link_to row.title, [:admin, row]
      	end	
      	column I18n.t('admin.org_title'), :sortable => :organisation_id do |org_title|
       		link_to org_title.organisation.name, [:admin, org_title.organisation]
    		end
      	
 		 	end
 		end
  
 	#form 	
 	form do |f|
  	f.inputs "Details" do
  		f.input :title
  		f.input :number
  		f.input :description
  		f.input :phase, :label => I18n.t('admin.phase_title'), 
  						:as => :select, 
  						:collection => Phase.order('title').map{|ph|[ph.title, ph.id]}
  		f.input :published  
  	end
  	f.actions  
  end		

	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
