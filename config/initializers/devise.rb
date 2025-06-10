# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Devise.setup do |config|
  # general configurations
  config.secret_key = Rails.application.credentials.secret_key
  config.mailer_sender = 'do-not-reply@dcc.ac.uk'
  require 'devise/orm/active_record'

  # case and whitespace handling
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # authentication settings
  config.http_authenticatable_on_xhr = false
  config.skip_session_storage = [:http_auth]

  # password settings
  config.stretches = Rails.env.test? ? 1 : 10
  config.pepper = Rails.application.credentials.devise_pepper
  config.password_length = 8..128

  # email reconfirmation
  config.reconfirmable = false

  # session and timeout setting
  config.timeout_in = 3.hours

  # reset password settings
  config.reset_password_within = 6.hours

  # navigation and sign-out settings
  config.navigational_formats = ['*/*', :html, :js]
  config.sign_out_via = :delete

  # omnitauth settings
  OmniAuth.config.full_host = ENV["HOST_URL"]
  OmniAuth.config.allowed_request_methods = [:post]
  config.omniauth_path_prefix = '/users/auth'
  
  # add omniauth logging
  OmniAuth.config.logger = Rails.logger 
  OmniAuth.config.on_failure = Proc.new { |env| Rails.logger.error(env) }

  # orcid omniauth strategy
  config.omniauth :orcid, {
    client_id: ENV["ORCID_CLIENT_ID"], 
    client_secret: ENV["ORCID_CLIENT_SECRET"], 
    member: ActiveModel::Type::Boolean.new.cast(ENV["ORCID_MEMBER"]), 
    sandbox: ActiveModel::Type::Boolean.new.cast(ENV["ORCID_SANDBOX"]),
    scope: "/authenticate"
  }


  # shibboleth omniauth strategy
  config.omniauth :shibboleth,
  {
    uid_field: "Remote-User",
    shib_application_id_field: "Shib-Application-ID",
    shib_session_id_field: "Shib-Session-ID",
    fields: [],
    info_fields: {
      affiliation: "HTTP_AFFILIATION",
    },
    extra_fields: [],
    request_type: :header,
  }

  # warden configurations
  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
end
# rubocop:enable Metrics/BlockLength
