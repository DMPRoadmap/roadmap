# frozen_string_literal: true

# Note that this file works in conjunction with the test routes defined at the bottom
# of the config/routes.rb file!

# Mock the Shibboleth Login URL
module AuthenticationHelper
  def mock_shibboleth(user:)
    url = "#{new_mocked_shib_idp_path}?email=#{user.email}"
    url += "&identity_provider=#{user.org&.identifier_for_scheme(scheme: 'shibboleth')&.value}"

    Rails.configuration.x.shibboleth.login_url = url
  end
end

# Mock Shibboleth IdP
class MockShibbolethIdentityProvidersController < ApplicationController
  # Mock Shibboleth IdP sign in form
  # GET /Shibboleth.sso/login
  def login
    html = <<~HTML
      <h1>Mock Shibboleth IdP Sign in form</h1>
      <form id="mock_shib_idp_sign_in" action="#{mocked_shib_idp_path}" method="POST">
        <label for="user_email">Email</label>
        <input type="email" value="#{params['email']}" name="user[email]" id="user_email" />

        <label for="user_password">Password</label>
        <input type="password" name="user[password]" id="user_password" value="#{SecureRandom.uuid}" />

        <input type="hidden" name="identity_provider" value="#{params['identity_provider']}"/>

        <button name="button" type="submit">Sign in</button>
      </form>
    HTML

    render html: html.html_safe
  end

  # Mock Shibboleth IdP sign in form submission
  # POST /Shibboleth.sso/Auth
  # rubocop:disable Metrics/AbcSize
  def auth
    # Expecting the identity_provider and user to be passed in from the form
    response.headers['omniauth.auth'] = {
      provider: 'shibboleth',
      uid: SecureRandom.uuid,
      info: {
        email: sign_in_params['email'],
        givenname: Faker::Movies::StarWars.character.split.first,
        sn: Faker::Movies::StarWars.character.split.first,
        identity_provider: params['identity_provider']
      }
    }

    p "REDIRECT TO CALLBACK: #{user_shibboleth_omniauth_callback_path}"

    code = params['identity_provider'].present? && sign_in_params[:email].present? ? 200 : 401
    redirect_to user_shibboleth_omniauth_callback_path, status: code
  end
  # rubocop:enable Metrics/AbcSize

  private

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end
end
