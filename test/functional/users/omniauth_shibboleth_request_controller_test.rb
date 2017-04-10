class OmniauthShibbolethRequestControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  
  #   user_omniauth_shibboleth  GET      /auth/shibboleth         users/omniauth_shibboleth_request#redirect
  #   user_shibboleth_assoc     GET      /auth/shibboleth/assoc   users/omniauth_shibboleth_request#associate
  
  setup do
    @schemes = IdentifierScheme.all
    @user = User.first
    
    @callback_uris = {}
    
    # Stub out shibboleth IDP responses
    OmniAuth.config.mock_auth[:shibboleth] = OmniAuth::AuthHash.new({
      :provider => "shibboleth",
      :idp => "blah",
      :uid => 'foo:bar'
    })
  end
  
  # -------------------------------------------------------------
  test "gets the IDP from the incoming params" do
    get user_omniauth_shibboleth_path
    assert_response :redirect
    assert_redirected_to "#{Rails.application.config.shibboleth_login}?target=%2Fusers%2Fauth%2Fshibboleth%2Fcallback"
    
    # Try it passing in an idp
    get "#{user_omniauth_shibboleth_path}?idp=foo"
    assert_response :redirect
    assert_redirected_to "#{Rails.application.config.shibboleth_login}?entityID=foo&target=%2Fusers%2Fauth%2Fshibboleth%2Fcallback"
  end
  
end