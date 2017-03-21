require 'test_helper'

class UsersControllerTest < ActionController::TestCase
=begin
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: @user.email, firstname: @user.firstname, last_login: @user.last_login, login_count: @user.login_count, orcid_id: @user.orcid_id, password: @user.password, shibboleth_id: @user.shibboleth_id, user_status_id: @user.user_status_id, surname: @user.surname, user_type_id: @user.user_type_id }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { email: @user.email, firstname: @user.firstname, last_login: @user.last_login, login_count: @user.login_count, orcid_id: @user.orcid_id, password: @user.password, shibboleth_id: @user.shibboleth_id, user_status_id: @user.user_status_id, surname: @user.surname, user_type_id: @user.user_type_id }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
=end
end
