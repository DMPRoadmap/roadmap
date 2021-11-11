# frozen_string_literal: true

module Users
  # Overrides to Devise's sign up registrations
  class RegistrationsController < Devise::RegistrationsController
    include Dmptool::Authenticatable

    # See the Authenticatable concern for additional callbacks

    before_action :configure_sign_up_params, only: [:create]

    before_action :configure_account_update_params, only: [:update]

    # rubocop:disable Metrics/AbcSize
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
      else
        # Devise doesn't set a flash message for some reason if its going to fail
        # so do it here
        super do |user|
          flash[:alert] = _('Unable to create your account!') unless user.valid?
        end
      end
    end
    # rubocop:enable Metrics/AbcSize

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
  end
end
