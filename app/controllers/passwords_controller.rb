class PasswordsController < Devise::PasswordsController
	
	protected
	
	def after_resetting_password_path_for(resource)
    render root_path
  end

end