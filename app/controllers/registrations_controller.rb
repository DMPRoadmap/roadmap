# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController

  def edit
    @user = current_user
    @prefs = @user.get_preferences(:email)
    @languages = Language.sorted_by_abbreviation
    @orgs = Org.order("name")
    @other_organisations = Org.where(is_other: true).pluck(:id)
    @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
    @default_org = current_user.org

    if !@prefs
      flash[:alert] = "No default preferences found (should be in branding.yml)."
    end
  end

  # GET /resource
  def new
    oauth = { provider: nil, uid: nil }
    IdentifierScheme.all.each do |scheme|
      unless session["devise.#{scheme.name.downcase}_data"].nil?
        oauth = session["devise.#{scheme.name.downcase}_data"]
      end
    end

    @user = User.new

    unless oauth.nil?
      # The OAuth provider could not be determined or there was no unique UID!
      if !oauth["provider"].nil? && !oauth["uid"].nil?
        # Connect the new user with the identifier sent back by the OAuth provider
        # rubocop:disable LineLength
        flash[:notice] = _("Please make a choice below. After linking your details to a %{application_name} account, you will be able to sign in directly with your institutional credentials.") % {
          application_name: Rails.configuration.branding[:application][:name]
        }
        # rubocop:enable LineLength
        scheme = IdentifierScheme.find_by(name: oauth["provider"].downcase)
        UserIdentifier.create(identifier_scheme: scheme,
                              identifier: oauth["uid"],
                              user: @user)
      end
    end
  end

  # POST /resource
  def create
    oauth = { provider: nil, uid: nil }
    IdentifierScheme.all.each do |scheme|
      unless session["devise.#{scheme.name.downcase}_data"].nil?
        oauth = session["devise.#{scheme.name.downcase}_data"]
      end
    end

    if params[:accept_terms].to_s == "0"
      redirect_to after_sign_up_error_path_for(resource),
        alert: _("You must accept the terms and conditions to register.")
    elsif params[:user][:org_id].blank? && params[:user][:other_organisation].blank?
      # rubocop:disable LineLength
      redirect_to after_sign_up_error_path_for(resource),
                alert: _("Please select an organisation from the list, or enter your organisation's name.")
      # rubocop:enable LineLength
    else
      existing_user = User.where_case_insensitive("email", sign_up_params[:email]).first
      if existing_user.present?
        if existing_user.invitation_token.present? && !existing_user.accept_terms?
          # Destroys the existing user since the accept terms are nil/false. and they
          # have an invitation Note any existing role for that user will be deleted too.
          # Added to accommodate issue at: https://github.com/DMPRoadmap/roadmap/issues/322
          # when invited user creates an account outside the invite workflow
          existing_user.destroy

        else
          redirect_to after_sign_up_error_path_for(resource),
            alert: _("That email address is already registered.")
          return
        end
      end

      if params[:user][:org_id].blank?
        other_org = Org.find_by(is_other: true)
        if other_org.nil?
          # rubocop:disable LineLength
          redirect_to(after_sign_up_error_path_for(resource),
            alert: _("You cannot be assigned to other organisation since that option does not exist in the system. Please contact your system administrators.")) and return
          # rubocop:enable LineLength
        end
        params[:user][:org_id] = other_org.id
      end

      build_resource(sign_up_params)
      if resource.save
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          UserMailer.welcome_notification(current_user).deliver_now
          unless oauth.nil?
            # The OAuth provider could not be determined or there was no unique UID!
            unless oauth["provider"].nil? || oauth["uid"].nil?
              prov = IdentifierScheme.find_by(name: oauth["provider"].downcase)
              # Until we enable ORCID signups
              if prov.name == "shibboleth"
                UserIdentifier.create(identifier_scheme: prov,
                                      identifier: oauth["uid"],
                                      user: @user)
                # rubocop:disable LineLength
                flash[:notice] = _("Welcome! You have signed up successfully with your institutional credentials. You will now be able to access your account with them.")
                # rubocop:enable LineLength
              end
            end
          end
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          if is_navigational_format?
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        end
      else
        clean_up_passwords resource
        # rubocop:disable LineLength
        redirect_to after_sign_up_error_path_for(resource),
                    alert: _("Unable to create your account.#{errors_for_display(resource)}")
        # rubocop:enable LineLength
      end
    end
  end

  def update
    if user_signed_in? then
      @prefs = @user.get_preferences(:email)
      @orgs = Org.order("name")
      @default_org = current_user.org
      @other_organisations = Org.where(is_other: true).pluck(:id)
      @identifier_schemes = IdentifierScheme.where(active: true).order(:name)
      @languages = Language.sorted_by_abbreviation
      if params[:skip_personal_details] == "true"
        do_update_password(current_user, params)
      else
        do_update(require_password = needs_password?(current_user, params))
      end
    else
      render(file: File.join(Rails.root, "public/403.html"), status: 403, layout: false)
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
    # added to by below, overwritten otherwise
    message = _("Save Unsuccessful. ")
    # ensure that the required fields are present
    if params[:user][:email].blank?
      message += _("Please enter an email address. ")
      mandatory_params &&= false
    end
    if params[:user][:firstname].blank?
      message += _("Please enter a First name. ")
      mandatory_params &&= false
    end
    if params[:user][:surname].blank?
      message += _("Please enter a Last name. ")
      mandatory_params &&= false
    end
    if params[:user][:org_id].blank? && params[:user][:other_organisation].blank?
      # rubocop:disable LineLength
      message += _("Please select an organisation from the list, or enter your organisation's name.")
      # rubocop:enable LineLength
      mandatory_params &&= false
    end
    # has the user entered all the details
    if mandatory_params
      # user is changing email or password
      if require_password
        # if user is changing email
        if current_user.email != params[:user][:email]
          # password needs to be present
          if params[:user][:password].blank?
            message = _("Please enter your password to change email address.")
            successfully_updated = false
          else
            successfully_updated = current_user.update_with_password(password_update)
            if !successfully_updated
              message = _("Save unsuccessful. That email address is already registered. You must enter a unique email address.")
            end
          end
        else
          # This case is never reached since this method when called with
          # require_password = true is because the email changed.
          # The case for password changed goes to do_update_password instead
          successfully_updated = current_user.update_without_password(update_params)
        end
      else
        # password not required
        successfully_updated = current_user.update_without_password(update_params)
      end
    else
      successfully_updated = false
    end

    # unlink shibboleth from user's details
    if params[:unlink_flag] == "true" then
      current_user.update_attributes(shibboleth_id: "")
    end

    # render the correct page
    if successfully_updated
      if confirm
        # will error out if confirmable is turned off in user model
        current_user.skip_confirmation!
        current_user.save!
      end
      session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
      # Method defined at controllers/application_controller.rb
      set_gettext_locale
      set_flash_message :notice, success_message(current_user, _("saved"))
      # Sign in the user bypassing validation in case his password changed
      sign_in current_user, bypass: true
      redirect_to "#{edit_user_registration_path}\#personal-details",
        notice: success_message(current_user, _("saved"))

    else
      flash[:alert] = message.blank? ? failure_message(current_user, _("save")) : message
      render "edit"
    end
  end

  def do_update_password(current_user, params)
    if params[:user][:current_password].blank?
      message = _("Please enter your current password")
    elsif params[:user][:password_confirmation].blank?
      message = _("Please enter a password confirmation")
    elsif params[:user][:password] != params[:user][:password_confirmation]
      message = _("Password and comfirmation must match")
    else
      successfully_updated = current_user.update_with_password(password_update)
    end
    # render the correct page
    if successfully_updated
      session[:locale] = current_user.get_locale unless current_user.get_locale.nil?
      # Method defined at controllers/application_controller.rbset_gettext_locale
      set_flash_message :notice, success_message(current_user, _("saved"))
      # TODO this method is deprecated
      sign_in current_user, bypass: true
      redirect_to "#{edit_user_registration_path}\#password-details",
        notice: success_message(current_user, _("saved"))

    else
      flash[:alert] = message.blank? ? failure_message(current_user, _("save")) : message
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
                                :language_id, :surname, :department_id)
  end

  def password_update
    params.require(:user).permit(:email, :firstname, :current_password,
                                :org_id, :language_id, :password,
                                :password_confirmation, :surname,
                                :other_organisation, :department_id)
  end

end
