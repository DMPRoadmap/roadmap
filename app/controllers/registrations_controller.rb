# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def edit
    @user.create_default_preferences if @user.prefs == {}
    @languages = Language.all.order("name")
    @orgs = Org.where(parent_id: nil).order("name")
    @other_organisations = Org.where(parent_id: nil, is_other: true).pluck(:id)
    @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
    @default_org = current_user.org
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
    if sign_up_params[:accept_terms] != "on" then
      redirect_to after_sign_up_error_path_for(resource), alert: _('You must accept the terms and conditions to register.')
    else
      sign_up_params[:accept_terms] = "1" # Convert the html 'on' to '1'
      existing_user = User.find_by_email(sign_up_params[:email])
      if !existing_user.nil? # If email exists
        if (existing_user.password == "" || existing_user.password.nil?) && existing_user.confirmed_at.nil? # If user has not accepted invitation yet
          existing_user.destroy # Only solution for now
          super
        else
          redirect_to after_sign_up_error_path_for(resource), alert: _('That email address is already registered.')
        end
      else
        build_resource(sign_up_params)
        if resource.save
          if resource.active_for_authentication?
            set_flash_message :notice, :signed_up if is_navigational_format?
            sign_up(resource_name, resource)
            UserMailer.welcome_notification(current_user).deliver
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
      @default_org = current_user.org
      @other_organisations = Org.where(parent_id: nil, is_other: true).pluck(:id)
      @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
      @languages = Language.sorted_by_abbreviation
      if params[:skip_personal_details] == "true"
        do_update_password(current_user, params)
      else
        do_update(require_password=needs_password?(current_user, params))
      end
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
    mandatory_params = true
    message = _('Save Unsuccessful.') + '  ' # added to by below, overwritten otherwise
    # ensure that the required fields are present
    if params[:user][:email].blank?
      message +=_('Please enter an email address.') + '  '
      mandatory_params &&= false
    end
    if params[:user][:firstname].blank?
      message +=_('Please enter a First name.') + '  '
      mandatory_params &&= false
    end
    if params[:user][:surname].blank?
      message +=_('Please enter a Last name.') + '  '
      mandatory_params &&= false
    end
    if params[:user][:org_id].blank?
      message += _('Please select an organisation, or select Other.')
      mandatory_params &&= false
    end
    if mandatory_params   # has the user entered all the details
      if require_password                              # user is changing email or password
        if current_user.email != params[:user][:email]   # if user is changing email
          if params[:user][:password].blank?       # password needs to be present
            message = _('Please enter your password to change email address.')
            successfully_updated = false
          else
            successfully_updated = current_user.update_with_password(password_update)
          end
        else                                           # potentially unreachable... but I dont like to leave off the else
          successfully_updated = current_user.update_with_password(password_update)
        end
      else                                             # password not required
        successfully_updated = current_user.update_without_password(update_params)
      end
    else
      successfully_updated = false
    end

    #unlink shibboleth from user's details
    if params[:unlink_flag] == 'true' then
      current_user.update_attributes(shibboleth_id: "")
    end

    #render the correct page
    if successfully_updated
      if confirm
        current_user.skip_confirmation! # will error out if confirmable is turned off in user model
        current_user.save!
      end
      session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
      set_gettext_locale  #Method defined at controllers/application_controller.rb
      set_flash_message :notice, _('Details successfully updated.')
      sign_in current_user, bypass: true  # Sign in the user bypassing validation in case his password changed
      redirect_to edit_user_registration_path, notice: _('Details successfully updated.')

    else
      flash[:notice] = message.blank? ? failed_update_error(current_user, _('profile')) : message
      render "edit"
    end
  end

  def do_update_password(current_user, params)
    if params[:user][:current_password].blank?
      message = _('Please enter your current password')
    elsif params[:user][:password_confirmation].blank?
      message = _('Please enter a password confirmation')
    elsif params[:user][:password] != params[:user][:password_confirmation]
      message = _('Password and comfirmation must match')
    else
      successfully_updated = current_user.update_with_password(password_update)
    end
    #render the correct page
    if successfully_updated
      if confirm
        current_user.skip_confirmation! # will error out if confirmable is turned off in user model
        current_user.save!
      end
      session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
      set_gettext_locale  #Method defined at controllers/application_controller.rb
      set_flash_message :notice, _('Details successfully updated.')
      sign_in current_user, bypass: true  # Sign in the user bypassing validation in case his password changed
      redirect_to edit_user_registration_path, notice: _('Details successfully updated.')

    else
      flash[:notice] = message.blank? ? failed_update_error(current_user, _('profile')) : message
      render "edit"
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :firstname, :surname, :recovery_email,
                                 :accept_terms, :other_organisation, :prefs)
  end

  def update_params
    params.require(:user).permit(:firstname, :org_id, :other_organisation,
                                :language_id, :surname, :prefs)
  end

  def password_update
    params.require(:user).permit(:email, :firstname, :current_password,
                                :org_id, :language_id, :password,
                                :password_confirmation, :surname,
                                :other_organisation, :prefs)
  end

end
