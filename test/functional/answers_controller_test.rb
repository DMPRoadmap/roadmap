require 'test_helper'

class AnswersControllerTest < ActionController::TestCase
  setup do
    set_form_authenticity_token
#    login_as_admin
    @answer = answers(:one)
  end

=begin
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:answers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
=end
  
  test "should create answer" do
    assert_difference('Answer.count') do
      post :create, answer: { text: @answer.text, plan_id: @answer.plan_id, question_id: @answer.question_id, user_id: @answer.user_id }
    end

    assert_redirected_to answer_path(assigns(:answer))
  end

=begin
  test "should show answer" do
    get :show, id: @answer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @answer
    assert_response :success
  end

  test "should update answer" do
    put :update, id: @answer, answer: { text: @answer.text, plan_id: @answer.plan_id, question_id: @answer.question_id, user_id: @answer.user_id }
    assert_redirected_to answer_path(assigns(:answer))
  end

  test "should destroy answer" do
    assert_difference('Answer.count', -1) do
      delete :destroy, id: @answer
    end

    assert_redirected_to answers_path
  end
=end
end
