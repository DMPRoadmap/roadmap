# frozen_string_literal: true

module Users
  # Overrides to Devise's sign up registrations
  class RegistrationsController < Devise::RegistrationsController
    include Dmptool::Authenticatable
    include OrgSelectable

    # See the Authenticatable concern for additional callbacks

    before_action :configure_sign_up_params, only: [:create]

    before_action :configure_account_update_params, only: [:update]

    # GET /users/sign_up
    def new
      @bypass_sso = params[:sso_bypass] == 'true'

      # See if there was any OmniAuth information. If so use it to prepoluate fields
      self.resource = user_from_omniauth
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # POST /users
    def create
      if resource.active_invitation? && !resource.new_record?
        # The user record already existed
        if resource.update(sign_up_params)
          resource.accept_invitation

          # Follow the standard Devise logic to sign in
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          # Follow the standard Devise failed registration logic
          clean_up_passwords resource
          set_minimum_password_length
          respond_with resource
        end
      elsif !Rails.configuration.x.recaptcha.enabled || verify_recaptcha(action: 'register')

        # Devise doesn't set a flash message for some reason if its going to fail
        # so do it here
        super do |user|
          flash[:alert] = _('Unable to create your account!') unless user.valid?

          # Attach the Shib eppn if this is part of an SSO account creation
          hash = session.fetch('devise.shibboleth_data', {})
          if hash.present? && user.valid?
            user.attach_omniauth_credentials(scheme_name: 'shibboleth',
                                             omniauth_hash: hash)
          end
        end
      else
        flash[:alert] = _('Invalid security check! Please make sure your browser is up to date and then try again')
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # PUT /resource
    # We need to use a copy of the resource because we don't want to change
    # the current user in place.
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
      args = process_params(resource)

      unless resource.errors.any?
        # if password is present then the user is trying to change the password
        resource_updated = resource.update_with_password(args) if args[:password].present?
        # else they are just updating their personal details
        resource_updated = resource.update_without_password(args) if args[:password].blank?
        # Change the locale if the user selected a different language
        session[:locale] = resource.language.abbreviation if resource.saved_change_to_language_id?
      end

      yield resource if block_given?
      if resource_updated
        set_flash_message_for_update(resource, prev_unconfirmed_email)
        bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?

        respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        set_minimum_password_length
        msg = [_('Unable to save your changes'), resource.errors.full_messages].join('<br>')
        redirect_to edit_user_registration_path, alert: msg
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(
        :sign_up, keys: authentication_params(type: :sign_up)
      )
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      devise_parameter_sanitizer.permit(
        :account_update, keys: authentication_params(type: :sign_up)
      )
    end

    # The path used after sign up.
    def after_sign_up_path_for(_resource)
      plans_path
    end

    # The default url to be used after updating a resource. You need to overwrite
    # this method in your own RegistrationsController.
    def after_update_path_for(resource)
      flash[:notice] = _('Your password has been updated') if resource.saved_change_to_encrypted_password?
      edit_user_registration_path
      # sign_in_after_change_password? ? signed_in_root_path(resource) : new_session_path(resource_name)
    end

    # Handle the Org autoccomplete and passwords
    def process_params(_resource)
      args = account_update_params

      # Convert the selected/specified Org name into attributes
      op = autocomplete_to_controller_params
      args[:org_id] = op[:org_id] if op[:org_id].present?
      args[:org_attributes] = op[:org_attributes] if op[:org_id].blank?
      args.delete(:org_attributes) if args[:org_attributes].blank?
      args
    end
  end
end
