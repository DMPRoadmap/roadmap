# frozen_string_literal: true

# Mock Shib IdP for authentication workflow tests
class MockShibbolethIdentityProvider
  # GET /Shibboleth.sso/login
  def login
    redirect_to user_shibboleth_omniauth_callback, status: :ok
  end
end
