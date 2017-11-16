require 'test_helper'

class AnswerLockingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    scaffold_plan
    @question = Question.create(text: 'Test question', section: @plan.template.phases.first.sections.first,
                                question_format: QuestionFormat.where(option_based: false).first, number: 99)

    @collaborator = (User.first == @plan.owner ? User.last : User.first)

    # Make the 2nd user an editor of the plan
    Role.create!(user_id: @collaborator.id, plan_id: @plan.id, access: 4)
    @plan.reload
  end

  # ----------------------------------------------------------
  test 'user receives not found when trying to save a non-existent answer' do
    userA = Answer.new(user: @plan.owner, plan: @plan, question: @question,
                       text: "Initial answer - by UserA")

    userB = Answer.new(user: @collaborator, plan: @plan, question: @question,
                       text: "Version conflict at onset - by UserB")

    # Signin as UserA and insert the new answer
    sign_in @plan.owner
    put answer_path(FastGettext.locale, userA, format: "json"), obj_to_params(userA.attributes)
    assert_response :not_found
    assert_equal "application/json", @response.content_type

    # Signin as UserB and try to insert the new answer but fail
    sign_in @collaborator
    put answer_path(FastGettext.locale, userB, format: "json"), obj_to_params(userB.attributes)
    assert_response :not_found
    assert_equal "application/json", @response.content_type
  end

  # ----------------------------------------------------------
  test 'user receives a lock notification if the answer was UPDATED while they were working' do
    userA = Answer.create!(user: @plan.owner, plan: @plan, question: @question,
                           text: "Initial answer - by UserA").attributes
    userB = userA.clone

    # Signin as UserA and insert the new answer
    sign_in @plan.owner
    userA['text'] += " - Updated by userA"

    put answer_path(FastGettext.locale, userA['id'], format: "json"), obj_to_params(userA)
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

    put answer_path(FastGettext.locale, userB['id'], format: "json"), obj_to_params(userB)
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
       answer: {id: attributes['id'],
                user_id: attributes['user_id'],
                plan_id: attributes['plan_id'],
                question_id: attributes['question_id'],
                text: attributes['text'],
                lock_version: attributes['lock_version']}
      }
    end
end
