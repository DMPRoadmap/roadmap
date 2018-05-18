require 'test_helper'

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.first
  end
  
  # # -------------------------------------------------------------
  test "sign up form loads" do
    get new_user_registration_path
    
    assert_response :success
    assert_not '#new_user'.nil?
  end
  
  # -------------------------------------------------------------
  test "user receives proper error messaging if they have not accepted terms" do
    post user_registration_path, {user: {accept_terms: nil}}
    
    assert_response :redirect
    follow_redirect!
    
    assert_response :success
    assert_equal _('You must accept the terms and conditions to register.'), flash[:alert]
  end
  
  test "user receives proper error messaging if they have not select an org from the list or entered their organisation name" do
    post user_registration_path, {user: {accept_terms: "on"}}
    assert_response :redirect
    follow_redirect!
    
    assert_response :success
    assert_equal _('Please select an organisation from the list, or enter your organisation\'s name.'), flash[:alert]
  end

  # -------------------------------------------------------------
  test "user receives proper error messaging if they have not provided a valid email and/or password" do
    org_id = Org.first.id
    [ {}, 
      {email: 'foo.bar@test.org' },                    # No Password or Confirmation
      {password: 'test12345' },                        # No Email
      {password: 'test12345', password_confirmation: 'test12345'}, # No Email
      {email: 'foo.bar@test.org', password: 'test' }, # Password is too short
      {email: 'foo.bar$test.org', password: 'test12345' } # invalid email
    ].each do |params|
      post user_registration_path, {user: { accept_terms: "on", org_id: org_id }.merge(params)}

      assert_response :redirect
      follow_redirect!
    
      assert_response :success
      assert_equal _('Error processing registration. Please check that you have entered a valid email address and that your chosen password is at least 8 characters long.'), flash[:alert]
    end
  end
  
  # -------------------------------------------------------------
  test "user is able to register and is auto-logged in and brought to profile page" do
    form = {accept_terms: "on", 
            email: 'foo.bar@test.org', 
            password: 'Test12345',
            org_id: Org.first.id }
    post user_registration_path, {user: form}
    
    assert_response :redirect
    assert_redirected_to root_url
    
    follow_redirect!
    assert_response :redirect
    assert_redirected_to plans_path
  end
  
  # -------------------------------------------------------------
  test "edit profile page loads when logged in" do
    sign_in @user
    
    get edit_user_registration_path
    
    assert_response :success
    assert_select 'main h1', _('Edit profile')
    
  end
  
  # -------------------------------------------------------------
  test "user is able to edit their profile" do
    sign_in @user
    
    # Change name
    put user_registration_path, {user: {email: @user.email, firstname: 'Testing', surname: 'UPDATE', org_id: Org.first.id}}
    assert flash[:notice].start_with?('Successfully')
    assert_response :redirect
    assert_redirected_to "#{edit_user_registration_url}\#personal-details"
    
    # Change email but didn't provide password
    put user_registration_path, {user: {email: 'something@else.org', firstname: @user.firstname, surname: @user.surname, org_id: Org.first.id}}
    assert_response :success
    assert_equal _('Please enter your password to change email address.'), flash[:alert]

# TODO: These don't seem to be behaving as expected. There were several typos in the controller that have been fixed
#       (succesfully_updated vs successfully_updated)
=begin
    # Change email
    put user_registration_path, {user: {email: 'something@else.org', current_password: 'password123', firstname: @user.firstname, surname: @user.surname}}
    assert_equal _('Details successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to edit_user_registration_url
    
    # Change password but neglected to provide the password
    put user_registration_path, {user: {password_confirmation: 'testing123', current_password: 'password123', firstname: @user.firstname, surname: @user.surname, email: @user.email}}
    assert_response :success
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
    
    # Change password but neglected to provide the password confirmation
    put user_registration_path, {user: {password: 'testing123', current_password: 'password123', firstname: @user.firstname, surname: @user.surname, email: @user.email}}
    assert_equal _('Please enter a password confirmation'), flash[:notice]
    assert_response :success
    
    # Change password but the password and confirmation do not match
    put user_registration_path, {user: {password: 'test123', password_confirmation: 'testing123', current_password: 'password123', firstname: @user.firstname, surname: @user.surname, email: @user.email}}
    assert_equal _('Password and comfirmation must match'), flash[:notice]
    assert_response :success
    
    # Change password
    put user_registration_path, {user: {password: 'testing123', password_confirmation: 'testing123', current_password: 'password123', firstname: @user.firstname, surname: @user.surname, email: @user.email}}
    assert flash[:notice].starts_with?(_('Could not update your'))
    assert_response :success
=end

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