# frozen_string_literal: true

# Mock the Shibboleth Login URL
module AuthenticationHelper
  # Bypasses the Omniauth call to the Shibboleth SP and the subsequent interaction on the
  # user's SSO form. It instead takes the email and eppn for the user you provide and sends
  # that directly to the callback controller
  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def mock_shibboleth(user:, success: true)
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]

    if success
      eppn = user.identifier_for_scheme(scheme: 'shibboleth')&.value

      # Generate the mock
      OmniAuth.config.add_mock(:shibboleth, {
                                 uid: eppn || SecureRandom.uuid,
                                 info: {
                                   email: user.email,
                                   givenname: user.firstname || Faker::Movies::StarWars.character.split.first,
                                   sn: user.surname || Faker::Movies::StarWars.character.split.first,
                                   identity_provider: user.org&.identifier_for_scheme(scheme: 'shibboleth')&.value
                                 }
                               })

      # Set the request.env to the mocked Shibboleth omniauth hash
      Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:shibboleth]
    else
      OmniAuth.config.mock_auth[:shibboleth] = :invalid_credentials
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # If you've called mock_shibboleth you should call this after your test runs
  def unmock_shibboleth
    OmniAuth.config.mock_auth[:shibboleth] = nil
  end
end

# Mock Shibboleth IdP
class MockShibbolethIdentityProvidersController < ApplicationController
  # GET /Shibboleth.sso/login
  def login
    # Bypass the Shibboleth SP page that redirects the user to their Org's IdP, and the login
    # form for the IdP
    redirect_to user_shibboleth_omniauth_callback_path
  end
end
