require 'test_helper'

class QuestionThemesControllerTest < ActionController::TestCase
=begin
  setup do
    @question_theme = question_themes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:question_themes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question_theme" do
    assert_difference('QuestionTheme.count') do
      post :create, question_theme: { question_id: @question_theme.question_id, theme_id: @question_theme.theme_id }
    end

    assert_redirected_to question_theme_path(assigns(:question_theme))
  end

  test "should show question_theme" do
    get :show, id: @question_theme
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question_theme
    assert_response :success
  end

  test "should update question_theme" do
    put :update, id: @question_theme, question_theme: { question_id: @question_theme.question_id, theme_id: @question_theme.theme_id }
    assert_redirected_to question_theme_path(assigns(:question_theme))
  end

  test "should destroy question_theme" do
    assert_difference('QuestionTheme.count', -1) do
      delete :destroy, id: @question_theme
    end

    assert_redirected_to question_themes_path
  end
=end
end
