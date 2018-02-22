class SessionsController < Devise::SessionsController
  
  def new
    redirect_to(root_path)
  end

  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  def create
    existing_user = User.find_by(email: params[:user][:email])
    if !existing_user.nil?
      
      ##Ldap Users password reset
      unless existing_user.encrypted_password.present?
        existing_user.valid_password?(params[:user][:password])
      end

      session[:locale] = existing_user.get_locale unless existing_user.get_locale.nil?
      set_gettext_locale  #Method defined at controllers/application_controller.rb
    end
    super
  end

  def destroy
    super
    session[:locale] = nil
    set_gettext_locale  #Method defined at controllers/application_controller.rb
  end
end
