require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
=begin
  setup do
    @question = questions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:questions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create question" do
    assert_difference('Question.count') do
      post :create, question: { default_value: @question.default_value, dependency_id: @question.dependency_id, dependency_text: @question.dependency_text, guidance: @question.guidance, order: @question.order, parent_id: @question.parent_id, suggested_answer: @question.suggested_answer, text: @question.text, type: @question.type, section_id: @question.section_id }
    end

    assert_redirected_to question_path(assigns(:question))
  end

  test "should show question" do
    get :show, id: @question
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @question
    assert_response :success
  end

  test "should update question" do
    put :update, id: @question, question: { default_value: @question.default_value, dependency_id: @question.dependency_id, dependency_text: @question.dependency_text, guidance: @question.guidance, order: @question.order, parent_id: @question.parent_id, suggested_answer: @question.suggested_answer, text: @question.text, type: @question.type, section_id: @question.section_id }
    assert_redirected_to question_path(assigns(:question))
  end

  test "should destroy question" do
    assert_difference('Question.count', -1) do
      delete :destroy, id: @question
    end

    assert_redirected_to questions_path
  end
=end
end
