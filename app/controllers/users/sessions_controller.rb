# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  include Dmptool::HomeController

  before_action :configure_sign_in_params, only: [:create]

  # This is a customization of the Devise action that displays the sign in form
  #
  # GET /resource/sign_in
  # def new
    # super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # This is a custom action that responds to a User having entered their email address
  #
  # POST /resource/validate
  def validate
    # The user entered their email address so try to determine if its an
    # existing user
    @user = User.includes(:org, :identifiers)
                .find_or_initialize_by(email: sign_in_params[:email])

    # Encrypt the email value and stuff it into the session for UI continuity since
    # Devise wants to redirect everything
    store_session_variable(
      name: :validation_token, payload: sign_in_params.to_h.to_json, purpose: :sign_in
    )
    # Redirect to the Homepage which will fetch the session vars to repopulate the
    # user's entries for the follow up sign in /sign up info
    redirect_to root_path
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:org_id])
  end

end
