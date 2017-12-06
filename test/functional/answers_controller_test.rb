require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.last
    scaffold_plan
  end

  # POST /answers/create_or_update
  test "should be able to create an answer" do
    sign_in @user

    # Test an answer for each Querstion Format
    QuestionFormat.all.each do |format|
      question = Question.find_by(question_format: format)
      template = question.section.phase.template

      plan = Plan.create(title: "Testing Answer For #{format.title}",
                         template: template, visibility: :is_test)

      Role.create!(user_id: @user.id, plan_id: plan.id, access: 4)

      form_attributes = {
                          answer: {
                            plan_id: plan.id,
                            question_id: question.id,
                            text: "Tested",
                            lock_version: 0 }
                          }
        
      post_create_or_update_answer(form_attributes)
      answer = Answer.find_by(plan: plan, question: question)
      assert_not answer.id.nil?, "expected the answer to have been updated and for an id to be present after creating a #{format.title} question!"
      assert_equal "Tested", answer.text, "expected the text to have been updated for a #{format.title} question!"
    end
  end

  private
    def post_create_or_update_answer(attributes)
      post create_or_update_answers_path(params: attributes)
      assert_response :success
      assert_equal "application/json", @response.content_type
    end
end
