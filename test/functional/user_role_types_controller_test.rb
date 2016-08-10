require 'test_helper'

class UserRoleTypesControllerTest < ActionController::TestCase
=begin
  setup do
    @user_role_type = user_role_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_role_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_role_type" do
    assert_difference('UserRoleType.count') do
      post :create, user_role_type: { description: @user_role_type.description, name: @user_role_type.name }
    end

    assert_redirected_to user_role_type_path(assigns(:user_role_type))
  end

  test "should show user_role_type" do
    get :show, id: @user_role_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_role_type
    assert_response :success
  end

  test "should update user_role_type" do
    put :update, id: @user_role_type, user_role_type: { description: @user_role_type.description, name: @user_role_type.name }
    assert_redirected_to user_role_type_path(assigns(:user_role_type))
  end

  test "should destroy user_role_type" do
    assert_difference('UserRoleType.count', -1) do
      delete :destroy, id: @user_role_type
    end

    assert_redirected_to user_role_types_path
  end
=end
end
