require 'test_helper'

class AnswerLockingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    scaffold_plan
    @question = Question.create(text: 'Test question', section: @plan.template.phases.first.sections.first,
                                question_format: QuestionFormat.where(option_based: false).first, number: 99)

    @owner = @plan.owner
    users = User.all
    @collaborator = users[users.find_index{ |u| u != @owner }]

    # Make the 2nd user an editor of the plan
    Role.create!(user_id: @collaborator.id, plan_id: @plan.id, access: 4)
    @plan.reload
  end

  test 'answer#create_or_update responds not_found when a plan does not exist' do
    userA = Answer.create!(user: @owner, question: @question,
                           text: "Initial answer - by UserA").attributes
    sign_in @owner
    params = obj_to_params(userA)
    params[:answer][:plan_id] = 'foo'
    post create_or_update_answers_path(params)
    assert_response :not_found
    assert_equal(_('There is no plan with id %{id} for which to create or update an answer') %{ :id => 'foo' }, ActiveSupport::JSON.decode(@response.body)['msg'])
  end

  test 'answer#create_or_update responds not found when a question does not exist for a plan' do
    userA = Answer.create!(user: @owner, plan: @plan,
                           text: "Initial answer - by UserA").attributes
    sign_in @owner
    params = obj_to_params(userA)
    params[:answer][:question_id] = 'foo'
    post create_or_update_answers_path(params)
    assert_response :not_found
    assert_equal(
      _("There is no question with id %{question_id} associated to plan id %{plan_id}"\
        "for which to create or update an answer") %{ :question_id => 'foo', :plan_id => @plan.id }, ActiveSupport::JSON.decode(@response.body)['msg'])
  end

  # ----------------------------------------------------------
  test 'user receives a lock notification if the answer was UPDATED while they were working' do
    userA = Answer.create!(user: @owner, plan: @plan, question: @question,
                           text: "Initial answer - by UserA").attributes
    userB = userA.clone

    # Signin as UserA and insert the new answer
    sign_in @plan.owner
    userA['text'] += " - Updated by userA"

    post create_or_update_answers_path(obj_to_params(userA))
    assert_response :success
    assert_equal "application/json", @response.content_type
    updated = Answer.find_by(plan: @plan, question: @question)
    assert_equal "Initial answer - by UserA - Updated by userA", updated.text
    assert_equal @plan.owner.id, updated.user_id

    # Make sure the answers/locking partial is NOT displayed
    assert_not @response.body.include?(_('The following answer cannot be saved')), "expected there to be no lock error messaging"
    assert @response.body.include?(_('Answered'))
    assert @response.body.include?("#{_(' by')} #{@plan.owner.name}"), "expected the messaging to say the plan was updated by the plan owner"

    # Signin as UserB and try to insert the new answer but fail
    sign_in @collaborator
    userB['text'] += " - Updated by userB"

    post create_or_update_answers_path(obj_to_params(userB))
    assert_response :success
    assert_equal "application/json", @response.content_type
    updated = Answer.find_by(plan: @plan, question: @question)
    assert_equal "Initial answer - by UserA - Updated by userA", updated.text
    assert_equal @plan.owner.id, updated.user_id

    # Make sure the answer-notice IS displayed
    assert @response.body.include?(_('The following answer cannot be saved')), "expected there to be lock error messaging"
    assert @response.body.include?(_('since %{name} saved the answer below while you were editing. Please, combine your changes and then save the answer again.') % { name: @plan.owner.name}), "expected the messaging to STILL say the plan was updated by the plan owner"
    assert @response.body.include?(_('Answered')), "expected the messaging to include the status"
  end

# ----------------------------------------------------------
  private
    def obj_to_params(attributes)
      {
       answer: {
        plan_id: attributes['plan_id'],
        question_id: attributes['question_id'],
        text: attributes['text'],
        lock_version: attributes['lock_version']}
      }
    end
end
