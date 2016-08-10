require 'test_helper'

class DmptemplatesControllerTest < ActionController::TestCase
=begin
  setup do
    @dmptemplate = dmptemplates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dmptemplates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dmptemplate" do
    assert_difference('Dmptemplate.count') do
      post :create, dmptemplate: { organisation_id: @dmptemplate.organisation_id, description: @dmptemplate.description, published: @dmptemplate.published, title: @dmptemplate.title, user_id: @dmptemplate.user_id }
    end

    assert_redirected_to dmptemplate_path(assigns(:dmptemplate))
  end

  test "should show dmptemplate" do
    get :show, id: @dmptemplate
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dmptemplate
    assert_response :success
  end

  test "should update dmptemplate" do
    put :update, id: @dmptemplate, dmptemplate: { organisation_id: @dmptemplate.organisation_id, description: @dmptemplate.description, published: @dmptemplate.published, title: @dmptemplate.title, user_id: @dmptemplate.user_id }
    assert_redirected_to dmptemplate_path(assigns(:dmptemplate))
  end

  test "should destroy dmptemplate" do
    assert_difference('Dmptemplate.count', -1) do
      delete :destroy, id: @dmptemplate
    end

    assert_redirected_to dmptemplates_path
  end
=end
end
