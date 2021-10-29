# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController

  include Dmptool::Authenticatable

  # See the Authenticatable concern for additional callbacks

  before_action :configure_sign_up_params, only: [:create]

  before_action :configure_account_update_params, only: [:update]

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
