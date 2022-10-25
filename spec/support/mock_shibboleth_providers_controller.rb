# frozen_string_literal: true

# Mock Shibboleth IdP
class MockShibbolethIdentityProvidersController < ApplicationController
  # GET /Shibboleth.sso/login
  def login
    # Bypass the Shibboleth SP page that redirects the user to their Org's IdP, and the login
    # form for the IdP
    redirect_to user_shibboleth_omniauth_callback_path
  end
end
