# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register QuestionOption do
	permit_params :question_id, :text, :number, :is_default 
	menu :priority => 6, :label => proc{I18n.t('admin.multi_options')}, :parent =>  "Templates management"

	index do   
        column :text
        column I18n.t('admin.questions'), :sortable => :question_id do |ques|
            if !ques.question_id.nil? then
                link_to ques.question.text, [:admin, ques.question]
            end  
        end
        column I18n.t('admin.sections'), :sortable => :question_id do |ques|
            if !ques.question_id.nil? then
                link_to ques.question.section.title, [:admin, ques.question.section]
            end
        end
        column I18n.t('admin.template'), :sortable => :question_id do |ques|
            if !ques.question_id.nil? then
                link_to ques.question.section.version.phase.dmptemplate.title, [:admin, ques.question.section.version.phase.dmptemplate]
            end  
        end
        
         actions
    end
  
    #show details of a section
    show do 
		attributes_table do
			row :text
	 		row	:number
	 		row I18n.t('admin.questions'), :question_id do |ques|
	 			if !ques.question_id.nil? then
	 				 link_to ques.question.text, [:admin, ques.question]
	 			end
            end
            row I18n.t('admin.sections'), :question_id do |ques|
                if !ques.question_id.nil? then
                    link_to ques.question.section.title, [:admin, ques.question.section]
                end
            end
            row I18n.t('admin.template'), :question_id do |ques|
                if !ques.question_id.nil? then
                     link_to ques.question.section.version.phase.dmptemplate.title, [:admin, ques.question.section.version.phase.dmptemplate]
                end
            end
            row :is_default
            row :created_at
            row :updated_at
		end
    end
  
  
    #form 
    form do |f|
        f.inputs "Details" do
            f.input :text
            f.input :number
            f.input :question, 
                    :as => :select, 
                    :collection => Question.order('text').map{ |sec| ["#{truncate(sec.section.version.phase.dmptemplate.title, :lengh => 20)} - #{truncate(sec.section.title, :lengh => 50)} - #{truncate(sec.text, :lengh => 20)}", sec.id] }
            f.input :is_default
        end
  	
        f.actions 
    end
	
	
	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
