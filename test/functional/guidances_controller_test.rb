require 'test_helper'

class GuidancesControllerTest < ActionController::TestCase
=begin
  setup do
    @guidance = guidances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:guidances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create guidance" do
    assert_difference('Guidance.count') do
      post :create, guidance: { file_id: @guidance.file_id, text: @guidance.text, organisation_id: @guidance.organisation_id, theme_id: @guidance.theme_id }
    end

    assert_redirected_to guidance_path(assigns(:guidance))
  end

  test "should show guidance" do
    get :show, id: @guidance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @guidance
    assert_response :success
  end

  test "should update guidance" do
    put :update, id: @guidance, guidance: { file_id: @guidance.file_id, text: @guidance.text, organisation_id: @guidance.organisation_id, theme_id: @guidance.theme_id }
    assert_redirected_to guidance_path(assigns(:guidance))
  end

  test "should destroy guidance" do
    assert_difference('Guidance.count', -1) do
      delete :destroy, id: @guidance
    end

    assert_redirected_to guidances_path
  end
=end
end
