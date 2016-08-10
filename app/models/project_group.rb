class ProjectGroup < ActiveRecord::Base

  	#associations between tables
  	belongs_to :project
  	belongs_to :user
  
  	attr_accessible :project_creator, :project_editor, :project_administrator, :project_id, :user_id, :email, :access_level, :as => [:default, :admin]
  
  	def email
  		unless user.nil? 
  			return user.email
  		end
  	end
  
  	def email=(new_email)
  		unless User.find_by_email(email).nil? then
			user = User.find_by_email(email)
		end
  	end
  
  	def access_level
  		if project_administrator then
  			return 3
  		elsif project_editor then
  			return 2
  		else
  			return 1
  		end
  	end
  	
  	def access_level=(new_access_level)
  		new_access_level = new_access_level.to_i
  		if new_access_level >= 3 then
  			project_administrator = true
  		else
  			project_administrator = false
  		end
  		if new_access_level >= 2 then
  			project_editor = true
  		else
  			project_editor = false
  		end
  	end
end
