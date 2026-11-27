# frozen_string_literal: true

Doorkeeper.configure do
  # set the object-relational-model (ORM)
  orm :active_record

  # ensure resource owner is authenticated
  resource_owner_authenticator do
    if request.path == native_oauth_authorization_path
      # Deactivate native_oauth_authorization_path (intended for mobile devices)
      redirect_to root_path, alert: "You are not authorized to perform this action."
    else
      # https://doorkeeper.gitbook.io/guides/ruby-on-rails/configuration
      current_user || warden.authenticate!(scope: :user)
    end
  end

  # ensure only super-admins can manage oauth applications
  admin_authenticator do |_routes|
    redirect_to root_path, alert: "You are not authorized to perform this action." unless current_user&.can_super_admin?
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

  # enable refresh tokens of duration 90 days
  use_refresh_token expiry: 90.days

  # enable ssl requirement for redirect url
  # - Allow HTTP in test and development environments
  force_ssl_in_redirect_uri !(Rails.env.test? || Rails.env.development?)

  hash_application_secrets
  hash_token_secrets
end
