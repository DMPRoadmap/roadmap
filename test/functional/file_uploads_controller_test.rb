require 'test_helper'

class FileUploadsControllerTest < ActionController::TestCase
=begin
  setup do
    @file_upload = file_uploads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:file_uploads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create file_upload" do
    assert_difference('FileUpload.count') do
      post :create, file_upload: { file_type_id: @file_upload.file_type_id, description: @file_upload.description, location: @file_upload.location, name: @file_upload.name, published: @file_upload.published, size: @file_upload.size, title: @file_upload.title }
    end

    assert_redirected_to file_upload_path(assigns(:file_upload))
  end

  test "should show file_upload" do
    get :show, id: @file_upload
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @file_upload
    assert_response :success
  end

  test "should update file_upload" do
    put :update, id: @file_upload, file_upload: { file_type_id: @file_upload.file_type_id, description: @file_upload.description, location: @file_upload.location, name: @file_upload.name, published: @file_upload.published, size: @file_upload.size, title: @file_upload.title }
    assert_redirected_to file_upload_path(assigns(:file_upload))
  end

  test "should destroy file_upload" do
    assert_difference('FileUpload.count', -1) do
      delete :destroy, id: @file_upload
    end

    assert_redirected_to file_uploads_path
  end
=end
end
