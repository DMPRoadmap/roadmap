# frozen_string_literal: true

require "custom_failure"

# rubocop:disable Metrics/BlockLength
Devise.setup do |config|
  require "devise/orm/active_record"

  config.mailer_sender = Rails.configuration.x.dmproadmap.do_not_reply_email

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10

  config.secret_key = Rails.configuration.x.dmproadmap.devise_secret
  config.pepper = Rails.configuration.x.dmproadmap.devise_pepper

  config.reconfirmable = false

  config.password_length = 8..72

  config.timeout_in = 3.hours

  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  # Omniauth Providers
  config.omniauth :orcid,
                  Rails.configuration.x.dmproadmap.orcid_client_id,
                  Rails.configuration.x.dmproadmap.orcid_client_secret,
                  member: true,
                  sandbox: Rails.configuration.x.dmproadmap.orcid_sandbox

  config.omniauth :shibboleth, {
    request_type: :header,
    uid_field: "eppn",
    info_fields: {
      email: "mail",
      name: "displayName",
      last_name: "sn",
      first_name: "givenName",
      identity_provider: "shib_identity_provider"
    },
    extra_fields: [:schacHomeOrganization],
    debug: false
  }

  config.omniauth_path_prefix = "/users/auth"

  config.warden do |manager|
    manager.failure_app = CustomFailure
  end
end
# rubocop:enable Metrics/BlockLength
