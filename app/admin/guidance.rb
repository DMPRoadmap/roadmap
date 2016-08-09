# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register Guidance do
	permit_params :text, :guidance_group_id,  :question_id
	
	menu :priority => 13, :label => proc{ I18n.t('admin.guidance')}, :parent => "Guidance list"
	 
	index do   
  		column (:text) { |guidance| raw(guidance.text) }
  		column I18n.t('admin.theme') do |t|
	 		 (t.themes.map{|t_q| link_to t_q.title, [:admin, t_q]}).join(', ').html_safe
        end	  
         		
        column I18n.t('admin.question'),  :sortable => :question_id do |que|
            if !que.nil? then
                que.question
            else
                '-'	
            end	
	    end
	    	
	    column I18n.t('admin.guidance_group') do |guidance| 
	    	(guidance.guidance_groups.map{|t_q| link_to t_q.name, [:admin, t_q]}).join(', ').html_safe
	    end  	
        actions
    end
  
    #show details of a question
	show do
		attributes_table do
			row (:text) { |guidance| raw(guidance.text) }
			
            row I18n.t('admin.theme') do
                (guidance.themes.map{|t_q| link_to t_q.title, [:admin, t_q]}).join(', ').html_safe
            end	
            row I18n.t('admin.question'), :question_id do |question|
                question.question
            end
            row I18n.t('admin.guidance_group') do |guidance| 
                (guidance.guidance_groups.map{|t_q| link_to t_q.name, [:admin, t_q]}).join(', ').html_safe
            end	
            
            row :created_at
            row :updated_at
		end
	end

	#form 
    form do |f|
        f.inputs "Details" do
            f.input :text
            f.input :question_id, :as => :select, 
                    :collection => Question.order('text').map{|que|[que.text, que.id]}
            f.input :guidance_group_ids, :label => I18n.t('admin.guidance_group'), 
                    :as => :select, 
                    :collection => GuidanceGroup.order('name').map{|gui|[gui.name, gui.id]}
            
        end
        f.inputs "Themes" do
            f.input :theme_ids, :label => I18n.t('admin.selected_themes'),
                    :as => :select, 
                    :include_blank => I18n.t('admin.all_themes'),
                    :multiple => true,
                    :collection => Theme.order('title').map{|the| [the.title, the.id]},
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
