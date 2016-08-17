require 'test_helper'

class OrganisationTypesControllerTest < ActionController::TestCase
=begin
  setup do
    @organisation_type = organisation_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organisation_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organisation_type" do
    assert_difference('OrganisationType.count') do
      post :create, organisation_type: { description: @organisation_type.description, name: @organisation_type.name }
    end

    assert_redirected_to organisation_type_path(assigns(:organisation_type))
  end

  test "should show organisation_type" do
    get :show, id: @organisation_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @organisation_type
    assert_response :success
  end

  test "should update organisation_type" do
    put :update, id: @organisation_type, organisation_type: { description: @organisation_type.description, name: @organisation_type.name }
    assert_redirected_to organisation_type_path(assigns(:organisation_type))
  end

  test "should destroy organisation_type" do
    assert_difference('OrganisationType.count', -1) do
      delete :destroy, id: @organisation_type
    end

    assert_redirected_to organisation_types_path
  end
=end
end
