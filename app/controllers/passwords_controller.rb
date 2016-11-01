class PasswordsController < Devise::PasswordsController
	
	protected
	
	def after_resetting_password_path_for(resource)
    root_path
  end
  
  ##
  # Override Devise default behaviour by sending user to the home page
  # after the password reset email has been sent
  #
  # @resource_name [String] The user's email address
  # ---------------------------------------------------------------------
  def after_sending_reset_password_instructions_path_for(resource_name)
    root_path
  end

end