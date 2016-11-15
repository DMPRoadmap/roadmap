# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Question do
	permit_params :default_value, :dependency_id, :dependency_text, :guidance, :number, :suggested_answer, :text, :question_type, :section_id
	
	menu :priority => 7, :label => proc{I18n.t('admin.question')}, :parent =>  "Templates management"

	index do  
        column I18n.t('admin.question'), :sortable => :text do |descr|
            if !descr.text.nil? then
                descr.text.html_safe
            end
        end	
        column I18n.t('admin.section_title'), :sortable => :section_id do |dmptemplate|
            if !dmptemplate.section_id.nil? then
                 link_to dmptemplate.section.title, [:admin, dmptemplate.section]
            end
        end
        column :number, :sortable => :number do |question_n|
            if !question_n.number.nil? then
             question_n.number
            end 
        end
        column I18n.t('admin.template_title'), :sortable => true do |dmptemplate|
             if !dmptemplate.section_id.nil? then
				if !dmptemplate.section.version.phase.dmptemplate.nil? then
					link_to dmptemplate.section.version.phase.dmptemplate.title, [:admin, dmptemplate.section.version.phase.dmptemplate]
				else 
					"-"
				end	
           end 
        end
        actions
    end
  
  
    #show details of a question
	show do
		attributes_table do
			row	:text do |descr|
                if !descr.text.nil? then
                    descr.text.html_safe
                end
            end	
	 		row :section_id do |question|
                link_to question.section.title, [:admin, question.section]
            end
	 		row :number
	 		row :default_value
	 		row I18n.t('admin.question_format') do |format|
	 			link_to format.question_format.title, [:admin, format.question_format]
	 		end
            row I18n.t('admin.themes') do
	 		 	(question.themes.map{|t_q| link_to t_q.title, [:admin, t_q]}).join(', ').html_safe
	 		end	
            row :created_at
            row :updated_at
	 		
	 	end	
	end


	#form 
    form do |f|
        f.inputs "Details" do
            f.input :text
            f.input :number
            f.input :section, 
  					:as => :select, 
  					:collection => Section.order('title').map{ |sec| ["#{sec.version.phase.dmptemplate.title} - #{sec.title}", sec.id] }
            f.input :default_value
            
        end
        f.inputs "Question Format" do
  			f.input :question_format_id, :label => I18n.t('admin.select_question_format'),
  					:as => :select,
  					:collection => QuestionFormat.order('title').map{|format| [format.title, format.id]}
        end
        f.inputs "Themes" do
  			f.input :theme_ids, :label => I18n.t('admin.selected_themes'),
                    :as => :select,
                    :multiple => true,
                    :include_blank => I18n.t('helpers.none'),
                    :collection => Theme.order('title').map{|the| [the.title, the.id]}	,
                    :hint => I18n.t('admin.choose_themes')
                    
        end
	 	f.actions  
    end	

	 controller do
		def permitted_params
		  params.permit!
		end
  end

end
