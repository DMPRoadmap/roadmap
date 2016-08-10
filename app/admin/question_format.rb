# [+Project:+] DMPonline
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre 

ActiveAdmin.register QuestionFormat do
	permit_params :description, :title
	
	menu :priority => 5, :label => proc{I18n.t('admin.question_format')}, :parent =>  "Templates management"

	index do   
        column I18n.t('admin.question_format'), :sortable => :title do |n|
            link_to n.title, [:admin, n]
        end
            
        actions
    end
  
    # show Template details
	show do 
		attributes_table do
			row :title
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
