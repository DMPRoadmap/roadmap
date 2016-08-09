# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Theme do
	permit_params :description, :title, :locale
	
	menu :priority => 12, :label => "Themes"

	index do    
		column :title , :sortable => :title do |theme|
			link_to theme.title, [:admin, theme]
		end
			column :description do |descr|
			if !descr.description.nil? then
				descr.description.html_safe
			end
		end
		
		actions
	end
  
	#show details of a theme
	show do
		attributes_table do
			row :title
			row :description
			row :created_at
			row :updated_at
		end	
	
		table_for( (Theme.find(params[:id]).questions).order('number')) do
	 		column (:number){|question| question.number} 
			column (I18n.t("admin.question")){|question| link_to question.text, [:admin, question]}
			column (I18n.t("admin.template")){|question| 
				if !question.section.nil? then
					if !question.section.version.nil? then
						if !question.section.version.phase.nil? then 
							if !question.section.version.phase.dmptemplate.nil? then
								link_to question.section.version.phase.dmptemplate.title, [:admin, question.section.version.phase.dmptemplate]
							else
								I18n.t('admin.no_template')
							end
						else
							I18n.t('admin.no_phase')
						end
					else
						I18n.t('admin.no_version')
					end
				else
					I18n.t('admin.no_section')
				end       
            }
		end	
	end
  
  
  
	#form
	form do |f|
		f.inputs "Details" do
			f.input :title
			f.input :description
		end
		f.actions  
	end			
	
	
	 controller do
		def permitted_params
		  params.permit!
		end
  end
	
end
