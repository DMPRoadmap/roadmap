class SessionsController < Devise::SessionsController
    
  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  def create
    existing_user = User.find_by(email: params[:user][:email])
    if !existing_user.nil?
      
# TODO: Not sure why we check for shib data in params and then use session value below. We should move this to the 
#       new user_identifiers table
      if !params[:shibboleth_data].nil? 
        #after authentication verify if session[:shibboleth] exists
        existing_user.update_attributes(shibboleth_id: session[:shibboleth_data][:uid])
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