# [+Project:+] DMPonline
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre 

ActiveAdmin.register Question do
	permit_params :default_value, :dependency_id, :dependency_text, :guidance, :number, :parent_id, :suggested_answer, :text, :question_type, :section_id
	
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
	 		#row :guidance do |qguidance|
             #   if !qguidance.guidance.nil? then
              #      qguidance.guidance.html_safe
              #  end
            #end	
            #row :parent_id do |qparent|
             #   if !qparent.parent_id.nil? then
              #      parent_q = Question.where('id = ?', qparent.parent_id)
               #     link_to parent_q.text, [:admin, parent_q]
            #    end
            #end
            #row :dependency_id do |qdepend|
             #   if !qdepend.dependency_id.nil? then
              #      qdep = Question.where('id = ?', qparent.dependency_id)
               #     link_to qdep.text, [:admin, qdep]
               # end
            #end
            #row :dependency_text do |dep_text|
             #   if !dep_text.dependency_text.nil? then
              #      dep_text.dependency_text.html_safe
               # end
            #end	
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
           # f.input :guidance 
           # f.input :parent_id, :label => "Parent", 
  			#		:as => :select, 
  			#		:collection => Question.find(:all, :order => 'text ASC').map{|que|[que.text, que.id]}
            #f.input :dependency_id, :label => "Dependency question", 
  			#		:as => :select, 
  		#			:collection => Question.find(:all, :order => 'text ASC').map{|que|[que.text, que.id]}
         #   f.input :dependency_text
            
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
