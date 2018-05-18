require 'test_helper'

class AnswerLockingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "super-admin-user-test@example.com", 
                         firstname: "Testing", surname: "User",
                         password: "password123", password_confirmation: "password123",
                         org: Org.last, accept_terms: true, confirmed_at: Time.zone.now)
  end
  
  test 'user can login when their account is active' do
    sign_in @user
    get root_path
    assert_authorized_redirect_to_plans_page
  end
  
  test 'user cannot login when their account is inactive' do
    @user.active = false
    @user.save!
    
    sign_in @user
    # Sign in throws an Exception when the user is inactive
    assert_raise do
      get root_path
    end
  end
  
  test 'logged in user is logged out when their account is deactivated' do
    sign_in @user
    get root_path
    assert_authorized_redirect_to_plans_page
    @user.active = false
    @user.save!
    get root_path
    assert_unauthorized_redirect_to_root_path
  end
end