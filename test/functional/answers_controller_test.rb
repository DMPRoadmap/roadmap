require 'test_helper'

class AnswersControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.last
    
    scaffold_plan
  end

  # PUT/PATCH /answer/[:id]
  # ----------------------------------------------------------
  test "should be able to update an answer" do
    sign_in @user
    
    # Test an answer for each Querstion Format
    QuestionFormat.all.each do |format|
      question = Question.find_by(question_format: format)
      template = question.section.phase.template
      
      plan = Plan.create(title: "Testing Answer For #{format.title}", 
                         template: template)
      
      Role.create!(user_id: @user.id, plan_id: plan.id, access: 4)
      plan.reload
                         
      referrer = "/#{FastGettext.locale}/plans/#{plan.id}/phases/#{question.section.phase.id}/edit"

      answer = Answer.find_by(plan: plan, question: question)
      assert_not answer.id.nil?, "expected the answer to have been created and for an id to be present after creating a #{format.title} question!"
                                                      
      # Try editing it
      form_attributes = {
                          answer: {id: answer.id,
                            user_id: @user.id, 
                            plan_id: answer.plan.id, 
                            question_id: answer.question.id,
                            text: "Tested",
                            lock_version: answer.lock_version}
                          }
        
      put_answer(answer, form_attributes, referrer)
      answer.reload
      assert_not answer.id.nil?, "expected the answer to have been updated and for an id to be present after creating a #{format.title} question!"
      assert_equal "Tested", answer.text, "expected the text to have been updated for a #{format.title} question!"
    end
  end
  
  
  private
    def put_answer(answer, attributes, referrer)
      put answer_path(FastGettext.locale, answer, format: "json"), attributes, {'HTTP_REFERER': referrer}

      assert_response :success
      assert_equal "application/json", @response.content_type
    end
end
