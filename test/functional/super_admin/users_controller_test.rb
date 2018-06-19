require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.create!(email: "super-admin-user-test@example.com", 
                         firstname: "Testing", surname: "User",
                         password: "password123", password_confirmation: "password123",
                         org: Org.last, accept_terms: true, confirmed_at: Time.zone.now)
    @super_admin = User.find_by(email: 'super_admin@example.com')
  end

  test 'unauthorized user cannot access edit user page' do
    get edit_super_admin_user_path(@user)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    get edit_super_admin_user_path(@user)
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can access edit user page' do  
    sign_in @super_admin
    get edit_super_admin_user_path(@user)
    assert_response :success
  end
  
  test 'unauthorized user cannot edit a user' do
    params = { firstname: 'Foo', surname: 'Bar' }
    put super_admin_user_path(@user), { user: params }
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    put super_admin_user_path(@user), { user: params }
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can edit a user' do  
    params = { firstname: 'Foo', surname: 'Bar' }
    sign_in @super_admin
    put super_admin_user_path(@user), { user: params }
    assert_response :redirect
    @user.reload
    assert_equal 'Foo', @user.firstname, "expected the User's firstname to have been updated"
  end

end
