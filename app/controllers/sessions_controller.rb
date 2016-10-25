class SessionsController < Devise::SessionsController

  def oauth_create
    existing_user = User.find_by_email(params[:user][:email])
    
    unless params[:omniauth].nil?
      
puts "OMNIAUTH: #{params[:omniauth].inspect}"
puts "REQUEST: #{request.env['omniauth.auth'].inspect}"
      
      existing_user = UserIdentifier.find_by(identifier: params[:omniauth][:auth])
      
    end

  end
  
  # Capture the user's shibboleth id if they're coming in from an IDP
  # ------------------------------------------------------------
  def create
    existing_user = User.find_by_email(params[:user][:email])
    
    if !existing_user.nil? && !params[:shibboleth_data].nil? then
      #after authentication verify if session[:shibboleth] exists
      existing_user.update_attributes(shibboleth_id: session[:shibboleth_data][:uid])
    end

    super
  end

end