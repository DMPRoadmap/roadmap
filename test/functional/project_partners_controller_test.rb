require 'test_helper'

class ProjectPartnersControllerTest < ActionController::TestCase
=begin
  setup do
    @project_partner = project_partners(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:project_partners)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project_partner" do
    assert_difference('ProjectPartner.count') do
      post :create, project_partner: { leader_org: @project_partner.leader_org, organisation_id: @project_partner.organisation_id, project_id: @project_partner.project_id }
    end

    assert_redirected_to project_partner_path(assigns(:project_partner))
  end

  test "should show project_partner" do
    get :show, id: @project_partner
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project_partner
    assert_response :success
  end

  test "should update project_partner" do
    put :update, id: @project_partner, project_partner: { leader_org: @project_partner.leader_org, organisation_id: @project_partner.organisation_id, project_id: @project_partner.project_id }
    assert_redirected_to project_partner_path(assigns(:project_partner))
  end

  test "should destroy project_partner" do
    assert_difference('ProjectPartner.count', -1) do
      delete :destroy, id: @project_partner
    end

    assert_redirected_to project_partners_path
  end
=end
end
