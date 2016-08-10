require 'test_helper'

class PlanSectionsControllerTest < ActionController::TestCase
=begin
  setup do
    @plan_section = plan_sections(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plan_sections)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plan_section" do
    assert_difference('PlanSection.count') do
      post :create, plan_section: { plan_id: @plan_section.plan_id, at: @plan_section.at, edit: @plan_section.edit, section_id: @plan_section.section_id, user_editing_id: @plan_section.user_editing_id }
    end

    assert_redirected_to plan_section_path(assigns(:plan_section))
  end

  test "should show plan_section" do
    get :show, id: @plan_section
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plan_section
    assert_response :success
  end

  test "should update plan_section" do
    put :update, id: @plan_section, plan_section: { plan_id: @plan_section.plan_id, at: @plan_section.at, edit: @plan_section.edit, section_id: @plan_section.section_id, user_editing_id: @plan_section.user_editing_id }
    assert_redirected_to plan_section_path(assigns(:plan_section))
  end

  test "should destroy plan_section" do
    assert_difference('PlanSection.count', -1) do
      delete :destroy, id: @plan_section
    end

    assert_redirected_to plan_sections_path
  end
=end
end
