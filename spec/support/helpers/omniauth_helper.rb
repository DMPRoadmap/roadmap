# frozen_string_literal: true

# Helper module for mocking OmniAuth authentication in tests
module OmniAuthHelper
  # This method sets and returns an OmniAuth::AuthHash
  # that simulates the authentication data returned by
  # an OmniAuth provider (e.g. Shibboleth).
  def mock_auth_hash(user, scheme)
    Rails.application.env_config['omniauth.auth'] =
      OmniAuth::AuthHash.new({
                               provider: scheme.name,
                               uid: '12345',
                               info: {
                                 email: user.email,
                                 first_name: user.firstname,
                                 last_name: user.surname
                               }
                             })
    Rails.application.env_config['omniauth.auth']
  end
end
