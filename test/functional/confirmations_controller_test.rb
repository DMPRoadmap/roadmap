require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers

  test 'make sure the user is redirected to the home page after confirming their email address' do
    @user = User.first
    @user.confirmed_at = nil
    @user.confirmation_token = 'ABCD1234'
    @user.confirmation_sent_at = Time.now
    @user.save!

    # Make sure invalid token results in
    get "#{root_url}/users/confirmation?confirmation_token=ZXYW0987"
    assert_response :success
    assert_select '.main_page_content h2', _('Resend confirmation instructions')

    get "#{root_url}/users/confirmation?confirmation_token=ABCD1234"
    assert_response :redirect
    assert_redirected_to root_url
    follow_redirects
    assert_select '.main_page_content h2', _('Welcome.')
    @user.reload
    assert_not @user.confirmed_at.nil?, "Expected the confirmed_at value to have been set!"
    
    # Make sure that we cannot reconfirm again
    get "#{root_url}/users/confirmation?confirmation_token=ABCD1234"
    assert_response :success
    assert_select '.main_page_content h2', _('Resend confirmation instructions')
    
  end

end