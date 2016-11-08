class OmniauthCallbacksController < ActionDispatch::IntegrationTest
  
  setup do

  end
  
  ##
  # Dynamically test the registered omniauth handlers
  # -------------------------------------------------------------
  test "should redirect to registration page if user is not already logged in and the omniauth provider does not supply correct information" do

    IdentifierScheme.all.each do |scheme|
      uri = Rails.application.routes.url_helpers.send(
                        "user_#{scheme.name.downcase}_omniauth_authorize_path")

      header = {"omniauth.auth": {
        "provider": "#{scheme.name.downcase}",
        "uid": "0000-0003-2012-0010",
        "info": {
          "name": "John Smith",
          "email": nil
        },
        "credentials": {
          "token": "e82938fa-a287-42cf-a2ce-f48ef68c9a35",
          "refresh_token": "f94c58dd-b452-44f4-8863-0bf8486a0071",
          "expires_at": 1979903874,
          "expires": true
        },
        "extra": {}
        }}

=begin
      # Not yet logged in, valid responses from provider
      # --------------------------------------------------------------
      post "#{uri}/callback", headers: headers

      assert_equal I18n.t('identifier_schemes.new_login_success'), flash[:notice], "Expected a success message when simulating a valid callback from #{scheme.name}"
      assert_redirected_to new_user_registration_url, "Expected a redirect to the registration page when the user is not logged in and we received a valid callback from #{scheme.name}"


      # Not yet logged in, invalid responses from provider
      # --------------------------------------------------------------
      confirm_invalid_provider_response(scheme.name, uri, nil)
      
      confirm_invalid_provider_response(scheme.name, uri, {'omniauth.auth': {}})
      
      confirm_invalid_provider_response(scheme.name, uri, {'omniauth.auth': {'provider': scheme.name.downcase}})
      
      confirm_invalid_provider_response(scheme.name, uri, {'omniauth.auth': {'uid': '123456'}})
=end
    end
  end

end