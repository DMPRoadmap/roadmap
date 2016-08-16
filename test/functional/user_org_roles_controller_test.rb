require 'test_helper'

class UserOrgRolesControllerTest < ActionController::TestCase
=begin
  setup do
    @user_role = user_org_roles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_org_roles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_org_role" do
    assert_difference('UserOrgRole.count') do
      post :create, user_org_role: { organisation_id: @user_org_role.organisation_id, user_id: @user_org_role.user_id, user_role_type_id: @user_org_role.user_role_type_id }
    end

    assert_redirected_to user_org_role_path(assigns(:user_org_role))
  end

  test "should show user_org_role" do
    get :show, id: @user_org_role
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_org_role
    assert_response :success
  end

  test "should update user_org_role" do
    put :update, id: @user_org_role, user_org_role: { organisation_id: @user_org_role.organisation_id, user_id: @user_org_role.user_id, user_role_type_id: @user_org_role.user_role_type_id }
    assert_redirected_to user_org_role_path(assigns(:user_org_role))
  end

  test "should destroy user_org_role" do
    assert_difference('UserOrgRole.count', -1) do
      delete :destroy, id: @user_org_role
    end

    assert_redirected_to user_org_roles_path
  end
=end
end
