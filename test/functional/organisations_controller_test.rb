require 'test_helper'

class OrganisationsControllerTest < ActionController::TestCase
=begin
  setup do
    @organisation = organisations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organisations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organisation" do
    assert_difference('Organisation.count') do
      post :create, organisation: { abbreviation: @organisation.abbreviation, banner_file_id: @organisation.banner_file_id, description: @organisation.description, domain: @organisation.domain, logo_file_id: @organisation.logo_file_id, name: @organisation.name, stylesheet_file_id: @organisation.stylesheet_file_id, target_url: @organisation.target_url, type_id: @organisation.type_id, wayfless_entite: @organisation.wayfless_entite }
    end

    assert_redirected_to organisation_path(assigns(:organisation))
  end

  test "should show organisation" do
    get :show, id: @organisation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @organisation
    assert_response :success
  end

  test "should update organisation" do
    put :update, id: @organisation, organisation: { abbreviation: @organisation.abbreviation, banner_file_id: @organisation.banner_file_id, description: @organisation.description, domain: @organisation.domain, logo_file_id: @organisation.logo_file_id, name: @organisation.name, stylesheet_file_id: @organisation.stylesheet_file_id, target_url: @organisation.target_url, type_id: @organisation.type_id, wayfless_entite: @organisation.wayfless_entite }
    assert_redirected_to organisation_path(assigns(:organisation))
  end

  test "should destroy organisation" do
    assert_difference('Organisation.count', -1) do
      delete :destroy, id: @organisation
    end

    assert_redirected_to organisations_path
  end
=end
end
