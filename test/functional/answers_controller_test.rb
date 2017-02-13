class AnswersControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.last
    
    scaffold_plan
  end

  # PUT/PATCH /[:locale]/answer/[:id]
  # ----------------------------------------------------------
  test "should be able to update an answer" do
    sign_in @user
    
    # Test an answer for each Querstion Format
    QuestionFormat.all.each do |format|
      question = Question.find_by(question_format: format)
      template = question.section.phase.template
      
      plan = Plan.create(title: "Testing Answer For #{format.title}", 
                         template: template)
                         
      referrer = "/#{I18n.locale}/plans/#{plan.id}/phases/#{question.section.phase.id}/edit"
                         
      answer = Answer.create(user: @user, plan: plan, question: question, 
                             text: "#{format.title} Tester")
                             
      if format.option_based
      
      else
        # Try creating one first
        form_attributes = {"answer-text-#{question.id}": "#{format.title} Tester", 
                           answer: {user_id: @user.id, plan_id: plan.id, 
                                    question_id: question.id}}
                                    
        put_answer(answer, form_attributes, referrer)
        
        answer = Answer.find_by(user: @user, plan: plan, question: question)
        assert_not answer.id.nil?, "expected the answer to have been created and for an id to be present after creating a #{format.title} question!"
                                    
        # Try editing it
        form_attributes = {"answer-text-#{question.id}": "Tested",
                           answer: {user_id: answer.user.id, 
                                    plan_id: answer.plan.id, 
                                    question_id: answer.question.id}}
        
        put_answer(answer, form_attributes, referrer)
        
        answer.reload
        
puts form_attributes.inspect
puts answer.inspect
        
        assert_not answer.id.nil?, "expected the answer to have been updated and for an id to be present after creating a #{format.title} question!"
        assert_equal "Tested", answer.text, "expected the text to have been updated for a #{format.title} question!"        
        
      end
    end
  end
  
  
  private
    def put_answer(answer, attributes, referrer)
      put answer_path(I18n.locale, answer), attributes, {'HTTP_REFERER': referrer}

      assert_equal I18n.t('helpers.project.answer_recorded'), flash[:notice]
      assert_response :redirect
      
      follow_redirects
      
      assert_response :success
      assert_select '.main_page_content h1', I18n.t("helpers.project.projects_title")
      
    end
end