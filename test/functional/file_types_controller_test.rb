require 'test_helper'

class FileTypesControllerTest < ActionController::TestCase
=begin
  setup do
    @file_type = file_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:file_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create file_type" do
    assert_difference('FileType.count') do
      post :create, file_type: { name: @file_type.name, icon_location: @file_type.icon_location, icon_name: @file_type.icon_name, icon_size: @file_type.icon_size }
    end

    assert_redirected_to file_type_path(assigns(:file_type))
  end

  test "should show file_type" do
    get :show, id: @file_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @file_type
    assert_response :success
  end

  test "should update file_type" do
    put :update, id: @file_type, file_type: { name: @file_type.name, icon_location: @file_type.icon_location, icon_name: @file_type.icon_name, icon_size: @file_type.icon_size }
    assert_redirected_to file_type_path(assigns(:file_type))
  end

  test "should destroy file_type" do
    assert_difference('FileType.count', -1) do
      delete :destroy, id: @file_type
    end

    assert_redirected_to file_types_path
  end
=end
end
