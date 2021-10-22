# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController

  before_action :configure_sign_in_params, only: [:create]

  # This is a customization of the Devise action that displays the sign in form
  #
  # GET /resource/sign_in
  # def new
    # super
  # end

  # POST /resource/sign_in
  def create
    if sign_in_params[:org_id].present?
      super
    else
      self.resource = User.includes(:org, :identifiers)
                          .find_or_initialize_by(email: sign_in_params[:email])

      resource.org = org_from_email_domain(email_domain: resource.email&.split("@")&.last)

p "EMAIL LENGTH: #{resource.email.length}"

      clean_up_passwords(resource)
      yield resource if block_given?

      @main_class = "js-heroimage"
      render resource.new_record? ? "users/registrations/new" : :new
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

=begin
  # This is a custom action that responds to a User having entered their email address
  #
  # POST /resource/validate
  def validate
    # The user entered their email address so try to determine if its an
    # existing user
    @user = User.includes(:org, :identifiers)
                .find_or_initialize_by(email: sign_in_params[:email])
  end
=end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:org_id])
  end

end
