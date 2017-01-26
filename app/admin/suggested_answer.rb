# [+Project:+] DMPRoadmap
# [+Description:+] 
#   
# [+Created:+] 03/09/2014
# [+Copyright:+] Digital Curation Centre and University of California Curation Center

ActiveAdmin.register SuggestedAnswer do
	permit_params :question_id, :organisation_id
	
	menu :priority => 4, :label => proc{I18n.t('admin.sug_answer')}, :parent => "Templates management"
	 
	 
	 #form 	
 	form do |f|
  	f.inputs "Details" do
  		f.input :question_id, :label => I18n.t('admin.question'), 
  						:as => :select, 
  						:collection => Question.order('text').map{|ques|[ques.text, ques.id]}
  		f.input :organisation_id, :label => I18n.t('admin.org_title'), 
  						:as => :select, 
  						:collection => Org.order('name').map{|orgp|[orgp.name, orgp.id]}
  		f.input :text
  		f.input :is_example
  	end
  	f.actions  
  end		

	 controller do
		def permitted_params
		  params.permit!
		end
  end
end
