require 'test_helper'

class UserStatusesControllerTest < ActionController::TestCase
=begin
  setup do
    @user_status = user_statuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_statuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_status" do
    assert_difference('UserStatus.count') do
      post :create, user_status: { description: @user_status.description, name: @user_status.name }
    end

    assert_redirected_to user_status_path(assigns(:user_status))
  end

  test "should show user_status" do
    get :show, id: @user_status
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_status
    assert_response :success
  end

  test "should update user_status" do
    put :update, id: @user_status, user_status: { description: @user_status.description, name: @user_status.name }
    assert_redirected_to user_status_path(assigns(:user_status))
  end

  test "should destroy user_status" do
    assert_difference('UserStatus.count', -1) do
      delete :destroy, id: @user_status
    end

    assert_redirected_to user_statuses_path
  end
=end
end
