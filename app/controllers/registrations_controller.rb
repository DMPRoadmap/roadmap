# frozen_string_literal: true

# Controller that handles user account creation and changes from the edit profile page
class RegistrationsController < Devise::RegistrationsController
  include OrgSelectable

  def edit
    @user = current_user
    @prefs = @user.get_preferences(:email)
    @languages = Language.sorted_by_abbreviation
    @orgs = Org.order('name')
    @other_organisations = Org.where(is_other: true).pluck(:id)
    @identifier_schemes = IdentifierScheme.for_users.order(:name)
    @default_org = current_user.org

    msg = 'No default preferences found (should be in dmproadmap.rb initializer).'
    flash[:alert] = msg unless @prefs
  end

  # GET /resource
  # rubocop:disable Metrics/AbcSize
  def new
    oauth = { provider: nil, uid: nil }
    IdentifierScheme.for_users.each do |scheme|
      oauth = session["devise.#{scheme.name.downcase}_data"] unless session["devise.#{scheme.name.downcase}_data"].nil?
    end

    @user = User.new

    # no oath, no provider or no uid - bail out
    return if oauth.nil? || oauth['provider'].nil? || oauth['uid'].nil?

    # Connect the new user with the identifier sent back by the OAuth provider
    flash[:notice] = format(_("Please make a choice below. After linking your
                       details to a %{application_name} account,
                       you will be able to sign in directly with your
                       institutional credentials."), application_name: ApplicationService.application_name)
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  # POST /resource
  def create
    oauth = { provider: nil, uid: nil }
    IdentifierScheme.for_users.each do |scheme|
      oauth = session["devise.#{scheme.name.downcase}_data"] unless session["devise.#{scheme.name.downcase}_data"].nil?
    end

    blank_org = if Rails.configuration.x.application.restrict_orgs
                  sign_up_params[:org_id]['id'].blank?
                else
                  sign_up_params[:org_id].blank?
                end

    if sign_up_params[:accept_terms].to_s == '0'
      redirect_to after_sign_up_error_path_for(resource),
                  alert: _('You must accept the terms and conditions to register.')
    elsif blank_org
      redirect_to after_sign_up_error_path_for(resource),
                  alert: _('Please select an organisation from the list, or choose Other.')
    else
      existing_user = User.where_case_insensitive('email', sign_up_params[:email]).first
      if existing_user.present?
        if existing_user.invitation_token.present? && !existing_user.accept_terms?
          # If the user is creating an account but they have an outstanding invitation, remember
          # any plans that were shared with the invitee so we can attach them to the new User record
          shared_plans = existing_user.roles
                                      .select(&:active?)
                                      .map { |role| { plan_id: role.plan_id, access: role.access } }
          existing_user.destroy
        else
          redirect_to after_sign_up_error_path_for(resource),
                      alert: _('That email address is already registered.')
          return
        end
      end

      # Handle the Org selection
      attrs = sign_up_params
      attrs = handle_org(attrs: attrs)

      # handle the language
      attrs[:language_id] = Language.default&.id unless attrs[:language_id].present?

      build_resource(attrs)

      # If the user is creating an account but they have an outstanding invitation, attach the shared
      # plan(s) to their new User record
      if shared_plans.present? && shared_plans.any?
        shared_plans.each do |role_hash|
          plan = Plan.find_by(id: role_hash[:plan_id])
          next unless plan.present?

          Role.create(plan: plan, user: resource, access: role_hash[:access], active: true)
        end
      end

      # Determine if reCAPTCHA is enabled and if so verify it
      use_recaptcha = Rails.configuration.x.recaptcha.enabled || false
      if (!use_recaptcha || verify_recaptcha(model: resource)) && resource.save
        # rubocop:disable Metrics/BlockNesting
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
          UserMailer.welcome_notification(current_user).deliver_now
          if !oauth.nil? && !(oauth['provider'].nil? || oauth['uid'].nil?)
            prov = IdentifierScheme.find_by(name: oauth['provider'].downcase)
            # Until we enable ORCID signups
            if prov.present? && prov.name == 'shibboleth'
              Identifier.create(identifier_scheme: prov,
                                value: oauth['uid'],
                                attrs: oauth,
                                identifiable: resource)
              flash[:notice] = _('Welcome! You have signed up successfully with your
                                  institutional credentials. You will now be able to access
                                  your account with them.')
            end
          end
          respond_with resource, location: after_sign_up_path_for(resource)
        elsif is_navigational_format?
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
        # rubocop:enable Metrics/BlockNesting
      else
        clean_up_passwords resource
        redirect_to after_sign_up_error_path_for(resource),
                    alert: _("Unable to create your account.#{errors_for_display(resource)}")

      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  # rubocop:disable Metrics/AbcSize
  def update
    if user_signed_in?
      @prefs = @user.get_preferences(:email)
      @orgs = Org.order('name')
      @default_org = current_user.org
      @other_organisations = Org.where(is_other: true).pluck(:id)
      @identifier_schemes = IdentifierScheme.for_users.order(:name)
      @languages = Language.sorted_by_abbreviation
      if params[:skip_personal_details] == 'true'
        do_update_password(current_user, update_params)
      else
        do_update(needs_password?(current_user))
      end
    else
      render(file: File.join(Rails.root, 'public/403.html'), status: 403, layout: false)
    end
  end
  # rubocop:enable Metrics/AbcSize

  private

  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user)
    user.email != update_params[:email] || update_params[:password].present?
  end

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:disable Style/OptionalBooleanParameter
  def do_update(require_password = true, confirm = false)
    restrict_orgs = Rails.configuration.x.application.restrict_orgs
    mandatory_params = true
    # added to by below, overwritten otherwise
    message = _('Save Unsuccessful. ')
    # ensure that the required fields are present

    if update_params[:email].blank?
      message += _('Please enter an email address. ')
      mandatory_params &&= false
    end
    if update_params[:firstname].blank?
      message += _('Please enter a First name. ')
      mandatory_params &&= false
    end
    if update_params[:surname].blank?
      message += _('Please enter a Last name. ')
      mandatory_params &&= false
    end
    if restrict_orgs && update_params[:org_id]['id'].blank?
      message += _("Please select an organisation from the list, or enter your organisation's name.")
      mandatory_params &&= false
    end
    # has the user entered all the details
    if mandatory_params

      # Handle the Org selection
      attrs = update_params
      attrs = handle_org(attrs: attrs)

      # user is changing email or password
      if require_password
        # if user is changing email
        if current_user.email == attrs[:email]
          # remove the current_password because its not actuallyt part of the User record
          attrs.delete(:current_password)

          # This case is never reached since this method when called with
          # require_password = true is because the email changed.
          # The case for password changed goes to do_update_password instead
          successfully_updated = current_user.update_without_password(attrs)
        elsif attrs[:password].blank?
          # password needs to be present
          message = _('Please enter your password to change email address.')
          successfully_updated = false
        elsif current_user.valid_password?(attrs[:current_password])
          successfully_updated = current_user.update_with_password(attrs)
          # rubocop:disable Metrics/BlockNesting
          unless successfully_updated
            message = _("Save unsuccessful. \
                That email address is already registered. \
                You must enter a unique email address.")
          end
          # rubocop:enable Metrics/BlockNesting
        else
          message = _('Invalid password')
        end
      else
        # password not required
        # remove the current_password because its not actuallyt part of the User record
        attrs.delete(:current_password)
        successfully_updated = current_user.update_without_password(attrs)
      end
    else
      successfully_updated = false
    end

    # unlink shibboleth from user's details
    current_user.update(shibboleth_id: '') if params[:unlink_flag] == 'true'

    # render the correct page
    if successfully_updated
      if confirm
        # will error out if confirmable is turned off in user model
        current_user.skip_confirmation!
        current_user.save!
      end
      session[:locale] = current_user.locale unless current_user.locale.nil?
      # Method defined at controllers/application_controller.rb
      set_locale
      set_flash_message :notice, success_message(current_user, _('saved'))
      # Sign in the user bypassing validation in case his password changed
      sign_in current_user, bypass: true
      redirect_to "#{edit_user_registration_path}#personal-details",
                  notice: success_message(current_user, _('saved'))

    else
      flash[:alert] = message.blank? ? failure_message(current_user, _('save')) : message
      @orgs = Org.order('name')
      render 'edit'
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  # rubocop:enable Style/OptionalBooleanParameter

  # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
  def do_update_password(current_user, args)
    if args[:current_password].blank?
      message = _('Please enter your current password')
    elsif args[:password_confirmation].blank?
      message = _('Please enter a password confirmation')
    elsif args[:password] != args[:password_confirmation]
      message = _('Password and comfirmation must match')
    else
      successfully_updated = current_user.update_with_password(args)
    end
    # render the correct page
    if successfully_updated
      session[:locale] = current_user.locale unless current_user.locale.nil?
      # Method defined at controllers/application_controller.rb#set_locale
      set_flash_message :notice, success_message(current_user, _('saved'))
      # TODO: this method is deprecated
      sign_in current_user, bypass: true
      redirect_to "#{edit_user_registration_path}#password-details",
                  notice: success_message(current_user, _('saved'))

    else
      flash[:alert] = message.blank? ? failure_message(current_user, _('save')) : message
      redirect_to "#{edit_user_registration_path}#password-details"
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/PerceivedComplexity

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation,
                                 :firstname, :surname, :recovery_email,
                                 :accept_terms, :org_id, :org_name,
                                 :org_crosswalk, :language_id)
  end

  def update_params
    params.require(:user).permit(:email, :firstname, :org_id, :language_id,
                                 :current_password, :password, :password_confirmation,
                                 :surname, :department_id, :org_id,
                                 :org_name, :org_crosswalk)
  end

  # Finds or creates the selected org and then returns it's id
  def handle_org(attrs:)
    return attrs unless attrs.present? && attrs[:org_id].present?

    org = org_from_params(params_in: attrs)

    # Remove the extraneous Org Selector hidden fields
    attrs = remove_org_selection_params(params_in: attrs)
    return attrs unless org.present?

    # reattach the org_id but with the Org id instead of the hash
    attrs[:org_id] = org.id
    attrs
  end
end
