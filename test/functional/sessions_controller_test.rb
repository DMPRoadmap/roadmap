require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  
  include Warden::Test::Helpers
  
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   new_user_session      GET      /users/sign_in     sessions#new
  #   user_session          POST     /users/sign_in     sessions#create
  #   destroy_user_session  DELETE   /users/sign_out    sessions#destroy
  
  setup do
    @user = User.first
  end

  # POST /users/sign_in (user_session_path)
  # ----------------------------------------------------------
  test "existing user's language setting is stored in the session and FastGettext" do
    @user.language = Language.find_by(abbreviation: 'de')
    @user.save!
    post user_session_path, {user: {email: @user.email}}
    assert_equal 'de', session[:locale], "expected the existing user's locale to have been set in the session"
    assert_response :redirect
    assert_redirected_to root_path
  end

  # POST /users/sign_in (user_session_path)
  # ----------------------------------------------------------
  test "unknown user's session[:locale] set to FastGettext.default_locale" do
    post user_session_path, {user: {email: 'testing.session@example.org'}}
    assert_nil session[:locale], "expected the new user's locale to be empty"
    assert_equal FastGettext.default_locale, FastGettext.locale, "expected the FastGettext to use the default locale"
    assert_response :redirect
    assert_redirected_to root_path
  end
  
  # POST /users/sign_in (user_session_path)
  # ----------------------------------------------------------
  test "existing user's Shibboleth id is captured" do
    Warden.on_next_request do |proxy|
      proxy.raw_session[:"devise.shibboleth_data"] = {uid: 'abcdefg'}
    end
    post user_session_path, {user: {email: @user.email}, shibboleth_data: {uid: 'abcdefg'}}
    assert_response :redirect
    assert_redirected_to root_path
    assert_equal 'abcdefg', @user.reload.shibboleth_id, "expected the existing user's shib id to have been set"
  end 
  
  # DELETE /users/sign_in (destroy_user_session_path)
  # ----------------------------------------------------------
  test "delete the user session" do
    delete destroy_user_session_path
    assert_nil session[:locale], "expected the locale to have been deleted from the session"
    assert_response :redirect
    if Rails.application.config.shibboleth_enabled
      assert_redirected_to Rails.application.config.shibboleth_logout_url + root_url
    else 
      assert_redirected_to root_path
    end
  end
  
end
