# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def edit
    @languages = Language.all.order("name")
    @orgs = Org.where(parent_id: nil).order("name")
    @other_organisations = Org.where(parent_id: nil, is_other: true).pluck(:id)
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
    #logger.debug "#{sign_up_params}"
  	if sign_up_params[:accept_terms] != "1" then
  	  redirect_to after_sign_up_error_path_for(resource), alert: _('You must accept the terms and conditions to register.')
  	else
  		existing_user = User.find_by_email(sign_up_params[:email])
  		if !existing_user.nil? then
  			if (existing_user.password == "" || existing_user.password.nil?) && existing_user.confirmed_at.nil? then
  				@user = existing_user
  				do_update(false, true)
  			else
          redirect_to after_sign_up_error_path_for(resource), alert: _('That email address is already registered.')
  			end
  		else
        build_resource(sign_up_params)
  			if resource.save
  			  if resource.active_for_authentication?
    				set_flash_message :notice, :signed_up if is_navigational_format?
    				sign_up(resource_name, resource)
    				respond_with resource, location: after_sign_up_path_for(resource)
  			  else
    				set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
    				#expire_session_data_after_sign_in!  <-- DEPRECATED BY DEVISE
    				respond_with resource, location: after_inactive_sign_up_path_for(resource)
  			  end
  			else
  			  clean_up_passwords resource
  			  redirect_to after_sign_up_error_path_for(resource), alert: _('Error processing registration. Please check that you have entered a valid email address and that your chosen password is at least 8 characters long.')
  			end
		  end
    end
  end


  def update
    if user_signed_in? then
      @orgs = Org.where(parent_id: nil).order("name")
      @other_organisations = Org.where(parent_id: nil, is_other: true).pluck(:id)
      @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
      @languages = Language.sorted_by_abbreviation
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
    user.email != params[:user][:email] || params[:user][:password].present?
  end

  def do_update(require_password = true, confirm = false)
	  if require_password then
		  successfully_updated = if needs_password?(current_user, params)
      current_user.update_with_password(params[:user])
      else
        # remove the virtual current_password attribute update_without_password
        # doesn't know how to ignore it
        params[:user].delete(:current_password)
        current_user.update_without_password(update_params)
      end
    else
    	current_user.update_attributes(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
    	successfully_updated = current_user.update_without_password(params[:user])
    end

    #unlink shibboleth from user's details
    if params[:unlink_flag] == 'true' then
      current_user.update_attributes(shibboleth_id: "")
    end

    if successfully_updated
  		if confirm then
  			current_user.skip_confirmation!
  			current_user.save!
  		end
        session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
        set_gettext_locale  #Method defined at controllers/application_controller.rb
        set_flash_message :notice, :updated
        sign_in current_user, bypass_sign_in: true  # Sign in the user bypassing validation in case his password changed
        redirect_to({:controller => "registrations", :action => "edit"}, {:notice => _('Details successfully updated.')})
    else
      render "edit"
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, 
                                 :accept_terms, :org_id, :other_organisation)
  end

  def update_params
    params.require(:user).permit(:email, :password, :firstname, :current_password,
                                 :org_id, :other_organisation, :language_id)
  end

end
