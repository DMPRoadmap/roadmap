class SessionsController < Devise::SessionsController

  # Capture the user's shibboleth id if they're coming in from an IDP
  def create
    existing_user = User.find_by(email: params[:user][:email])
    if !existing_user.nil? && !params[:shibboleth_data].nil? then
      #after authentication verify if session[:shibboleth] exists
      existing_user.update_attributes(shibboleth_id: session[:shibboleth_data][:uid])
    end

    super
  end

end