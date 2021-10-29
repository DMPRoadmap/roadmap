# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  include Dmptool::Authenticatable

  # See the Authenticatable concern for additional callbacks

  before_action :configure_sign_in_params, only: [:create]

  # POST /resource/sign_in
  def create
    if !sign_in_params[:email].present?
      # If the email was left blank display an error
      redirect_to root_path, alert: _("Invalid email address!")

    elsif resource&.invitation_token&.present? && !resource&.accepted_or_not_invited?
      # The user has an open invitation
      clean_up_passwords(resource)

      # Clear out the stub values used to make the initial invited User valid
      resource.firstname = nil
      resource.surname = nil
      resource.org = nil

      render "users/invitations/edit"

    elsif sign_in_params[:org_id].present?
      # If there is an Org in the params then this is step 2 of the email+password workflow
      # so just let Devise sign them in normally
      super

    else
      # If there is no Org then the user provided their email in step 1 so we need
      # to send them to the Sign in OR Sign up page
      clean_up_passwords(resource)
      render resource.new_record? ? "users/registrations/new" : :new
    end
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: authentication_params(type: :sign_in))
  end

end
