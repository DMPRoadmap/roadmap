require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.first
  end
  
  # -------------------------------------------------------------
  test "sign up form loads" do
    get new_user_registration_path
    
    assert_response :success
    assert_not '#new_user'.nil?
  end
  
  # -------------------------------------------------------------
  test "user receives proper error messaging if they have not accepted terms" do
    post user_registration_path, {user: {accept_terms: false}}
    
    assert_response :redirect
    follow_redirect!
    
    assert_response :success
    assert_equal _('You must accept the terms and conditions to register.'), flash[:alert]
  end
  
  # -------------------------------------------------------------
  test "user receives proper error messaging if they have not provided a valid email and/or password" do
    [ {}, 
      {email: 'foo.bar@test.org'},                    # No Password or Confirmation
      {password: 'test12345'},                        # No Confirmation
      {password_confirmation: 'test12345'},           # No Password
      {password: 'test12345', password_confirmation: 'test12345'}, # No Email
      {email: 'foo.bar@test.org', password: 'test', password_confirmation: 'test'}, # Password is too short
      {email: 'foo.bar@test.org', password: 'test12345', password_confirmation: 'test123'}, # Passwords do not match
      {email: 'foo.bar$test.org', password: 'test12345', password_confirmation: 'test12345'} # invalid email
    ].each do |params|
      post user_registration_path, {user: {accept_terms: 1}.merge(params)}
    
      assert_response :redirect
      follow_redirect!
    
      assert_response :success
      assert_equal _('Error processing registration. Please check that you have entered a valid email address and that your chosen password is at least 8 characters long.'), flash[:alert]
    end
  end
  
  # -------------------------------------------------------------
  test "user is able to register and is auto-logged in and brought to profile page" do
    form = {accept_terms: 1, 
            email: 'foo.bar@test.org', 
            password: 'Test12345', 
            password_confirmation: 'Test12345'}
    
    cntr = 1
    # Test the bare minimum requirements and then all options
    [form, form.merge({email: "foo.bar#{cntr}@test.org", 
                       organisation_id: Org.first.id})].each do |params|
      post user_registration_path, {user: params}
    
      assert_response :redirect
      assert_redirected_to root_url
    
      follow_redirect!
      assert_response :success
      assert_equal I18n.t('devise.registrations.signed_up_but_unconfirmed'), flash[:notice]
      assert_select '.welcome-message h2', _('Welcome.')
      
      cntr += 1
    end
  end
  
  # -------------------------------------------------------------
  test "edit profile page loads when logged in" do
    sign_in @user
    
    get edit_user_registration_path
    
    assert_response :success
    assert_select '.main_page_content h1', _('Edit profile')
    
  end
  
  # -------------------------------------------------------------
  test "user is able to edit their profile" do
    sign_in @user
    
    put user_registration_path, {user: {firstname: 'Foo', surname: 'Bar'}}
  
    assert_response :success
    assert_equal nil, flash[:notice]
    assert_select '.main_page_content h1', _('Edit profile')
  end
  
# INVALID AUTH REROUTING CHECKS
  # -------------------------------------------------------------
  test "sign up form does NOT load if already logged in" do
    sign_in @user
    get new_user_registration_path
    
    assert_authorized_redirect_to_plans_page
  end
  
  # -------------------------------------------------------------
  test "edit profile page does NOT load if not logged in" do
    get edit_user_registration_path
    
    assert_unauthorized_redirect_to_root_path 
  end
  
  # -------------------------------------------------------------
  test "can NOT edit profile if not logged in" do
    post user_registration_path, {user: {firstname: 'Foo', surname: 'Bar'}}
    
    assert_unauthorized_redirect_to_root_path
  end
end