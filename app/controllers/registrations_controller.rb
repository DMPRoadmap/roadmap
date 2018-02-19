# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def edit
    @user = current_user
    @prefs = @user.get_preferences(:email)
    @languages = Language.sorted_by_abbreviation
    @orgs = Org.where(parent_id: nil).order("name")
    @other_organisations = Org.where(parent_id: nil, is_other: true).pluck(:id)
    @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
    @default_org = current_user.org

    if !@prefs
      flash[:alert] = 'No default preferences found (should be in branding.yml).'
    end
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
      if oauth['provider'].nil? || oauth['uid'].nil?
        # flash[:alert] = _('We were unable to verify your account. Please use the following form to create a new account. You will be able to link your new account afterward.')
      else
        # Connect the new user with the identifier sent back by the OAuth provider
        flash[:notice] = _('Please make a choice below. After linking your details to a %{application_name} account, you will be able to sign in directly with your institutional credentials.') % {application_name: Rails.configuration.branding[:application][:name]}
        UserIdentifier.create(identifier_scheme: IdentifierScheme.find_by(name: oauth['provider'].downcase),
                              identifier: oauth['uid'],
                              user: @user)
      end
    end
  end

  # POST /resource
  def create
    oauth = {provider: nil, uid: nil}
    IdentifierScheme.all.each do |scheme|
      oauth = session["devise.#{scheme.name.downcase}_data"] unless session["devise.#{scheme.name.downcase}_data"].nil?
    end

    if !sign_up_params[:accept_terms]
      redirect_to after_sign_up_error_path_for(resource), alert: _('You must accept the terms and conditions to register.')
    elsif params[:user][:org_id].blank? && params[:user][:other_organisation].blank?
      redirect_to after_sign_up_error_path_for(resource), alert: _('Please select an organisation from the list, or enter your organisation\'s name.')
    else
      existing_user = User.where_case_insensitive('email', sign_up_params[:email]).first
      if existing_user.present?
        if existing_user.accept_terms?
          redirect_to after_sign_up_error_path_for(resource), alert: _('That email address is already registered.')
          return
        else
          existing_user.destroy # Destroys the existing user since the accept terms are nil/false.
          # Note any existing role for that user will be deleted too. Added to accommodate issue at:
          # https://github.com/DMPRoadmap/roadmap/issues/322
        end
      end
        if params[:user][:org_id].blank?
          other_org = Org.find_by(is_other: true)
          if other_org.nil?
            redirect_to(after_sign_up_error_path_for(resource), alert: _('You cannot be assigned to other organisation since that option does not exist in the system. Please contact your system administrators.')) and return
          end
          params[:user][:org_id] = other_org.id 
        end
        build_resource(sign_up_params)
        if resource.save
          if resource.active_for_authentication?
            set_flash_message :notice, :signed_up if is_navigational_format?
            sign_up(resource_name, resource)
            UserMailer.welcome_notification(current_user).deliver
            unless oauth.nil?
              # The OAuth provider could not be determined or there was no unique UID!
              unless oauth['provider'].nil? || oauth['uid'].nil?
                prov = IdentifierScheme.find_by(name: oauth['provider'].downcase)
                # Until we enable ORCID signups
                if prov.name == 'shibboleth'
                  UserIdentifier.create(identifier_scheme: prov,
                                        identifier: oauth['uid'],
                                        user: @user)
                  flash[:notice] = _('Welcome! You have signed up successfully with your institutional credentials. You will now be able to access your account with them.')
                end
              end
            end
            respond_with resource, location: after_sign_up_path_for(resource)
          else
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          clean_up_passwords resource
          redirect_to after_sign_up_error_path_for(resource), alert: _('Error processing registration. Please check that you have entered a valid email address and that your chosen password is at least 8 characters long.')
        end
    end
  end

  def update
    if user_signed_in? then
      @prefs = @user.get_preferences(:email)
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
    if params[:user][:org_id].blank? && params[:user][:other_organisation].blank?
      message += _('Please select an organisation from the list, or enter your organisation\'s name.')
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
        else                                           # user did not change their email so no pwd required
          successfully_updated = current_user.update_without_password(update_params)
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
      set_flash_message :notice, success_message(_('profile'), _('saved'))
      sign_in current_user, bypass: true  # Sign in the user bypassing validation in case his password changed
      redirect_to "#{edit_user_registration_path}\#personal-details", notice: success_message(_('profile'), _('saved'))

    else
      flash[:alert] = message.blank? ? failed_update_error(current_user, _('profile')) : message
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
      session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
      set_gettext_locale  #Method defined at controllers/application_controller.rb
      set_flash_message :notice, success_message(_('password'), _('saved'))
      sign_in current_user, bypass: true  # Sign in the user bypassing validation in case his password changed
      redirect_to "#{edit_user_registration_path}\#password-details", notice: success_message(_('password'), _('saved'))

    else
      flash[:alert] = message.blank? ? failed_update_error(current_user, _('profile')) : message
      redirect_to "#{edit_user_registration_path}\#password-details"
    end
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :firstname, :surname, :recovery_email,
                                 :accept_terms, :org_id, :other_organisation)
  end

  def update_params
    params.require(:user).permit(:firstname, :org_id, :other_organisation,
                                :language_id, :surname)
  end

  def password_update
    params.require(:user).permit(:email, :firstname, :current_password,
                                :org_id, :language_id, :password,
                                :password_confirmation, :surname,
                                :other_organisation)
  end

end
