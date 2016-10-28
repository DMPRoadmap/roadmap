class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  ##
  # Dynamically build a handler for each omniauth provider
  # -------------------------------------------------------------
  IdentifierScheme.all.each do |scheme|
    define_method(scheme.name.downcase) do
      handle_omniauth(scheme)
    end
  end

  ##
  # Processes callbacks from an omniauth provider and directs the user to 
  # the appropriate page:
  #   Not logged in and uid had no match ---> Sign Up page
  #   Not logged in and uid had a match ---> Sign In and go to Home Page
  #   Signed in and uid had no match --> Save the uid and go to the Profile Page
  #   Signed in and uid had a match --> Go to the Home Page
  #
  # @scheme [IdentifierScheme] The IdentifierScheme for the provider
  # -------------------------------------------------------------
  def handle_omniauth(scheme)
    user = User.from_omniauth(request.env["omniauth.auth"])
    
    # If the user isn't logged in
    if current_user.nil? 
      session["devise.#{scheme.name.downcase}_data"] = request.env["omniauth.auth"]
      
      # If the uid didn't have a match in the system send them to register
      if user.email.nil?
        redirect_to new_user_registration_url
        
      # Otherwise sign them in
      else
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: scheme.name) if is_navigational_format?
      end
      
    # The user is just registering the uid with us
    else
      # If the user could not be found by that uid then attach it to their record
      if user.email.nil? || user.email.empty?
        UserIdentifier.create!(identifier_scheme: scheme, 
                               identifier: request.env["omniauth.auth"].uid,
                               user: current_user)
      end
      
      redirect_to edit_user_registration_path
    end
  end

=begin
  # We could consider combining these callbacks into a shared generic version
  # -------------------------------------------------------------
  def orcid
    scheme = IdentifierScheme.find_by(name: request.env["omniauth.auth"].provider.upcase)
    user = User.from_omniauth(request.env["omniauth.auth"])
    
    # If the user isn't logged in
    if current_user.nil? 
      session["devise.orcid_data"] = request.env["omniauth.auth"]
      
      # If the uid didn't have a match in the system send them to register
      if user.email.nil?
        redirect_to new_user_registration_url
        
      # Otherwise sign them in
      else
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Orcid') if is_navigational_format?
      end
      
    # The user is just registering the uid with us
    else
      # If the user could not be found by that uid then attach it to their record
      if user.email.nil? || user.email.empty?
        UserIdentifier.create!(identifier_scheme: scheme, 
                               identifier: request.env["omniauth.auth"].uid,
                               user: current_user)
      end
      
      redirect_to edit_user_registration_path
    end
  end
=end
  
  # -------------------------------------------------------------
  def shibboleth
    if user_signed_in? && current_user.shibboleth_id.present? && current_user.shibboleth_id.length > 0 then
      flash[:warning] = I18n.t('devise.failure.already_authenticated')
      redirect_to root_path
    else
      auth = request.env['omniauth.auth'] || {}
      eppn = auth['extra']['raw_info']['eppn']
      uid = nil
      if !eppn.blank? then
        uid = eppn
      elsif !auth['uid'].blank? then
        uid = auth['uid']
      elsif !auth['extra']['raw_info']['targeted-id'].blank? then
        uid = auth['extra']['raw_info']['targeted-id']
      end

      if !uid.nil? && !uid.blank? then
				s_user = User.where(shibboleth_id: uid).first
				# Take out previous record if was not confirmed.
				if !s_user.nil? && s_user.confirmed_at.nil? then
					sign_out s_user
					User.delete(s_user.id)
					s_user = nil
				end

				# Stops Shibboleth ID being blocked if email incorrectly entered.
				if !s_user.nil? && s_user.try(:persisted?) then
					flash[:notice] = I18n.t('devise.omniauth_callbacks.success', :kind => 'Shibboleth')
					sign_in s_user
                    redirect_to root_path
				else
					if user_signed_in? then
						current_user.update_attribute('shibboleth_id', uid)
						user_id = current_user.id
						sign_out current_user
						session.delete(:shibboleth_data)
						s_user = User.find(user_id)
						sign_in s_user
                        redirect_to edit_user_registration_path
					else
						session[:shibboleth_data] = request.env['omniauth.auth']
						session[:shibboleth_data][:uid] = uid
						redirect_to new_user_registration_url(:nosplash => 'true')
					end
				end
      else
        redirect_to root_path
      end
    end
  end

  # -------------------------------------------------------------
  def failure
    redirect_to root_path
  end
end
