# frozen_string_literal: true

Doorkeeper.configure do # rubocop:todo Metrics/BlockLength
  # set the object-relational-model (ORM)
  orm :active_record

  # ensure resource owner is authenticated
  resource_owner_authenticator do
    if user_signed_in?
      if request.path == "/oauth/authorize/native"
        # the /oauth/authorize/native path is only used for mobile devices
        # and so it is better to deactivate it
        redirect_to root_path, alert: "You are not authorized to perform this action."
      else
        current_user
      end
    else
      # preserve oauth2 request url before redirecting to login
      session[:user_return_to] = request.fullpath if request.get?

      # redirect user to login page
      redirect_to new_user_session_url
    end
  end

  # ensure only super-admins can manage oauth applications
  admin_authenticator do |_routes|
    if current_user
      unless current_user.can_super_admin?
        redirect_to root_path, alert: "You are not authorized to perform this action."
      end
    else
      warden.authenticate!(scope: :user)
    end
  end

  # grant flows enabled
  # Authorization Code Grant Flow (ACGF)
  grant_flows %w[authorization_code client_credentials]

  # allow for redirect-uri to be blank
  # (required for client_credentials apps for org-admins)
  allow_blank_redirect_uri true

  # scopes enabled
  default_scopes :read

  # ensure client apps cannot ask for scopes outwith those specified here
  enforce_configured_scopes

  # set the token endpoint configurations
  access_token_expires_in 2.hours
  reuse_access_token

  # enable refresh tokens of duration 90 days
  use_refresh_token expiry: 90.days

  # enable ssl requirement for redirect url
  force_ssl_in_redirect_uri true
end
