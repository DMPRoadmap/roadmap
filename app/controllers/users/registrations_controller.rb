# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  include Dmptool::Authenticatable

  # See the Authenticatable concern for additional callbacks

  before_action :configure_sign_up_params, only: [:create]

  before_action :configure_account_update_params, only: [:update]

  # This is a customization of the Devise action that creates a new user account
  # It was copied over verbatim. The modifications are noted below:
  #
  # POST /resource
  def create

pp sign_up_params.inspect

    super

  end

=begin
  def create
    # super

    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length

      # Encrypt the form values and any validation errrors and stuff it into the session
      # for UI continuity since Devise wants to redirect everything

      flash[:alert] = "Unable to create your account!"
      render :new
    end
  end
=end

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
  def after_sign_up_path_for(resource)
    plans_path
  end

end
