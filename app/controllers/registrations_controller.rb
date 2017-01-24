# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def edit
    @languages = Language.order("name")
    @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
  end

  # GET /resource
  def new
    oauth = {provider: nil, uid: nil}
    IdentifierScheme.all.each do |scheme|
      oauth = session["devise.#{scheme.name.downcase}_data"] unless session["devise.#{scheme.name.downcase}_data"].nil?
    end
    
    @user = User.new
    
    unless oauth.nil?
      # The OAuth provider could not be determined or there was no unique UID!
      if oauth[:provider].nil? || oauth[:uid].nil?
        flash[:notice] = t('identifier_schemes.new_login_failure')

      else
        # Connect the new user with the identifier sent back by the OAuth provider
        flash[:notice] = t('identifier_schemes.new_login_success')
        UserIdentifier.create(identifier_scheme: oauth[:provider].upcase, 
                              identifier: oauth[:uid],
                              user: @user)
      end
    end
  end

  # POST /resource
  def create
    logger.debug "#{sign_up_params}"
  	if sign_up_params[:accept_terms] != "1" then
  	  redirect_to after_sign_up_error_path_for(resource), alert: I18n.t('helpers.you_must_accept')
  	else
  		existing_user = User.find_by_email(sign_up_params[:email])
  		if !existing_user.nil? then
            redirect_to after_sign_up_error_path_for(resource), alert: I18n.t('helpers.email_already_registered')
  		else
			build_resource(sign_up_params)
			if resource.save
			  if resource.active_for_authentication?
  				set_flash_message :notice, :signed_up if is_navigational_format?
  				sign_up(resource_name, resource)
  				respond_with resource, :location => after_sign_up_path_for(resource)
			  else
  				set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
  				#expire_session_data_after_sign_in!  <-- DEPRECATED BY DEVISE
  				respond_with resource, :location => after_inactive_sign_up_path_for(resource)
			  end
			else
			  clean_up_passwords resource
			  redirect_to after_sign_up_error_path_for(resource), alert: I18n.t('helpers.error_registration_check')
			end
		end
    end
  end


  def update
    if user_signed_in? then
      @user = User.find(current_user.id)
      @languages = Language.order("name")
      @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
      
      do_update
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email != params[:user][:email] ||
      params[:user][:password].present?
  end

  def do_update(require_password = true, confirm = false)
	  if require_password then
		  successfully_updated = if needs_password?(@user, params)
      @user.update_with_password(params[:user])
      else
        # remove the virtual current_password attribute update_without_password
        # doesn't know how to ignore it
        params[:user].delete(:current_password)
        @user.update_without_password(params[:user])
      end
    else
    	@user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
    	successfully_updated = @user.update_without_password(params[:user])
    end

    # If the user selected a new language setting, go ahead and reset the locale
    if params[:user][:language_id]
      if @user.language_id != params[:user][:language_id]
        params[:locale] = Language.find(params[:user][:language_id]).abbreviation
        set_locale 
      end
    end
    
    #unlink shibboleth from user's details
    if params[:unlink_flag] == 'true' then
      @user.update_attributes(:shibboleth_id => "")
    end

    if successfully_updated
  		if confirm then
  			@user.skip_confirmation!
  			@user.save!
  		end
        set_flash_message :notice, :updated
        # Sign in the user bypassing validation in case his password changed
        sign_in @user, bypass_sign_in: true
        #sign_in @user, :bypass => true
        
        #if params[:unlink_flag] == 'true' then
            redirect_to({:controller => "registrations", :action => "edit"}, {:notice => I18n.t('helpers.project.details_update_success')})
        #else
        #    redirect_to({:controller => "projects", :action => "index"}, {:notice => I18n.t('helpers.project.details_update_success')})
        #end

    else
      render "edit"
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :accept_terms, 
                                 :organisation_id, :other_organisation)
  end

end
