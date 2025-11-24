# frozen_string_literal: true

# Helper module for mocking OmniAuth authentication in tests
module OmniAuthHelper
  # This method sets and returns an OmniAuth::AuthHash
  # that simulates the authentication data returned by
  # an OmniAuth provider (e.g. Shibboleth).
  def mock_auth_hash(user, scheme)
    # Ensure Devise correctly maps the :user model for OmniAuth in tests.
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
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

  # Manually define an action in Users::OmniauthCallbacksController.
  # These actions are dynamically defined in the controller (based on IdentifierScheme entries).
  # Because required db entries may not yet exist when the controller is loaded in the test environment,
  # an action can be explicitly defined here for the test to work.
  def define_omniauth_callback_for(scheme)
    # Only define the action if it passes the .for_authentication validation
    return unless IdentifierScheme.for_authentication.exists?(id: scheme.id)

    Users::OmniauthCallbacksController.define_method(scheme.name.downcase) do
      handle_omniauth(scheme)
    end
  end
end
