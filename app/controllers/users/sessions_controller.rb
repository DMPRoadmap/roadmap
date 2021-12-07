# frozen_string_literal: true

module Users
  # Overrides to Devise's sign in/out sessions
  class SessionsController < Devise::SessionsController
    include Dmptool::Authenticatable

    # See the Authenticatable concern for additional callbacks

    before_action :configure_sign_in_params, only: [:create]

    # POST /resource/sign_in
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def create
      if !sign_in_params[:email].present?
        # If the email was left blank display an error
        redirect_to root_path, alert: _('Invalid email address!')

      elsif sign_in_params[:org_id].present?
        # If there is an Org in the params then this is step 2 of the email+password workflow
        # so just let Devise sign them in normally
        super

      else
        # If there is no Org then the user provided their email in step 1 so we need
        # to send them to the Sign in OR Sign up page
        clean_up_passwords(resource)

        # If this is a user with an invitation, then clean up the stub data
        active_invite = resource.active_invitation?
        resource.firstname = nil if active_invite
        resource.surname = nil if active_invite
        resource.org = nil if active_invite

        is_new_user = resource.new_record? || active_invite
        render is_new_user ? 'users/registrations/new' : :new
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    protected

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_in_params
      devise_parameter_sanitizer.permit(:sign_in, keys: authentication_params(type: :sign_in))
    end
  end
end
