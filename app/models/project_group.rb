class ProjectGroup < ActiveRecord::Base

	#associations between tables
	belongs_to :project
	belongs_to :user

	attr_accessible :project_creator, :project_editor, :project_administrator, :project_id, :user_id, :email, :access_level, :as => [:default, :admin]

  ##
  # returns the user's email unless it is nil
  #
  # @return [Boolean, String] false if no email exists, the email otherwise
	def email
		unless user.nil? 
			return user.email
		end
	end

  ##
  # define a new user for the project group by email
  #
  # @param new_email [String] the email of the new user for the project group
  # @return [User] the new user
	def email=(new_email)
		unless User.find_by(email: email).nil? then
		user = User.find_by(email: email)
    end
	end

  ##
  # return the access level for the current project group
  # 3 if the user is an administrator
  # 2 if the user is an editor
  # 1 if the user can only read
  #
  # @return [Integer]
	def access_level
		if project_administrator then
			return 3
		elsif project_editor then
			return 2
		else
			return 1
		end
	end

  ##
  # define a new access level for the current project group
  # if >=3, the user is a project administrator
  # if >=2, the user is an editor
  #
  # @param new_access_level [Integer] the access level to give the user
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
