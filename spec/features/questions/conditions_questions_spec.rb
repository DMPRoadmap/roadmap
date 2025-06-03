# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Question::Conditions questions', type: :feature do
  include ConditionalQuestionsHelper
  before(:each) do
    @user = create(:user)
    @template = create(:template, :default, :published)
    @plan = create(:plan, template: @template)
    @phase = create(:phase, template: @template)
    # 3 sections for ensuring that conditions involve questions in different sections.
    @section1 = create(:section, phase: @phase)
    @section2 = create(:section, phase: @phase)
    @section3 = create(:section, phase: @phase)

    # Different types of questions (than can have conditional options)
    @conditional_questions = create_conditional_questions(3)

    # Questions that do not have conditional options for adding or removing
    @non_conditional_questions = create_non_conditional_questions(3, 3)

    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)

    @all_questions_ids = (@conditional_questions.values + @non_conditional_questions.values.flatten).map(&:id)
    @total_initial_questions = @all_questions_ids.count

    # Answer the non-conditional questions
    answers = create_answers
    @total_initial_answers = answers.values.flatten.count

    sign_in(@user)

    # Ensure mailer box empty before test.
    ActionMailer::Base.deliveries = []
  end

  # NOTE: Condition is only implemented for checkboxes, radio buttons and dropdowns. In these cases, currently
  # the option_list only takes one option in the UI.
  # As functionality for more than option per condition does not yet exist in code.
  #  So all Conditions are created with option_list with a single option id.

  describe 'conditions with action_type remove' do
    feature 'User answers a question with a condition' do
      scenario 'User answers chooses an option with a condition', :js do
        # Choose a conditional question at random (may be of type :checkbox, :radiobutton, or :dropdown)
        question_type = @conditional_questions.keys.sample
        conditional_question = @conditional_questions[question_type]
        conditional_question_remove_option = conditional_question.question_options[0]
        conditional_question_other_option = conditional_question.question_options[1]
        answer_id = conditional_question.id
        condition = create(:condition, question: conditional_question,
                                       option_list: [conditional_question_remove_option.id],
                                       action_type: 'remove',
                                       remove_data: [@non_conditional_questions[:textarea][0].id,
                                                     @non_conditional_questions[:textfield][1].id,
                                                     @non_conditional_questions[:date][2].id,
                                                     @non_conditional_questions[:rda_metadata][0].id,
                                                     @non_conditional_questions[:checkbox][1].id,
                                                     @non_conditional_questions[:radiobutton][2].id,
                                                     @non_conditional_questions[:dropdown][0].id,
                                                     @non_conditional_questions[:multiselectbox][1].id])

        go_to_write_plan_page_and_verify_answered

        # Answer the conditional_question
        within("#answer-form-#{answer_id}") do
          answer_conditional_question(conditional_question_remove_option, question_type)
        end

        check_answer_save_statuses(answer_id)
        check_question_and_answer_counts_for_plan(condition.remove_data)
        check_remove_data_effect_on_answer_form_selectors(condition.remove_data)

        question_option = determine_question_option(conditional_question_remove_option,
                                                    conditional_question_other_option, question_type)
        # If :checkbox, uncheck the previously checked option
        # Else, select a different :dropdown/:radiobutton option
        within("#answer-form-#{answer_id}") do
          answer_conditional_question(question_option, question_type, 'uncheck')
        end

        check_answer_save_statuses(answer_id)
        num_questions, num_answers = question_and_answer_counts_for_plan

        # Undoing the conditional question should unhide all of the `remove_data` questions
        # `-= 1` is needed for :checkbox because unchecking removes an answer
        # (:dropdown and :radiobutton simply select a different answer)
        num_answers -= 1 if question_type == :checkbox
        expect(page).to have_text("#{num_answers}/#{num_questions} answered")
      end

      scenario 'User answers chooses an option without a condition', :js do
        # Choose a conditional question at random (may be of type :checkbox, :radiobutton, or :dropdown)
        question_type = @conditional_questions.keys.sample
        conditional_question = @conditional_questions[question_type]
        conditional_question_other_option = conditional_question.question_options[0]
        answer_id = conditional_question.id
        create(:condition, question: conditional_question,
                           option_list: [conditional_question.question_options[1].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(2))

        create(:condition, question: conditional_question,
                           option_list: [conditional_question.question_options[2].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(0))

        go_to_write_plan_page_and_verify_answered

        # Answer the conditional_question
        within("#answer-form-#{answer_id}") do
          answer_conditional_question(conditional_question_other_option, question_type)
        end

        check_answer_save_statuses(answer_id)
        check_question_and_answer_counts_for_plan
      end
    end
  end

  describe 'conditions with action_type add_webhook' do
    scenario 'User answers chooses an option with a condition (with action_type: add_webhook)', :js do
      # Choose a conditional question at random (may be of type :checkbox, :radiobutton, or :dropdown)
      question_type = @conditional_questions.keys.sample
      conditional_question = @conditional_questions[question_type]
      conditional_question_webhook_option = conditional_question.question_options[2]
      answer_id = conditional_question.id
      condition = create(:condition, :webhook, question: conditional_question,
                                               option_list: [conditional_question_webhook_option.id])

      go_to_write_plan_page_and_verify_answered

      # Answer the conditional_question
      within("#answer-form-#{answer_id}") do
        answer_conditional_question(conditional_question_webhook_option, question_type)
      end

      check_answer_save_statuses(answer_id)
      check_question_and_answer_counts_for_plan

      check_delivered_mail_for_webhook_data_and_question_data(JSON.parse(condition.webhook_data), :checkbox)
    end
  end

  private

  def check_question_and_answer_counts_for_plan(condition_remove_data = nil)
    if condition_remove_data
      check_condition_remove_data_effect_on_plan(condition_remove_data.count)
    else
      # This is either a :webhook type conditional question, or a non-conditional question
      num_questions, num_answers = question_and_answer_counts_for_plan
      expect(page).to have_text("#{num_answers}/#{num_questions} answered")
    end
  end

  def check_condition_remove_data_effect_on_plan(num_removed_answers)
    num_questions, num_answers = question_and_answer_counts_for_plan
    # The number of plan questions has not changed in the db
    expect(num_questions).to eql(@total_initial_questions)
    # The number of plan answers in the db has changed:
    # - We subract num_removed_answers (i.e. `condition.remove_data.count`)
    # - We also `+ 1` to account for the answer saved for the conditional question in the process
    expected_num_answers = @total_initial_answers - num_removed_answers + 1
    expect(num_answers).to eql(expected_num_answers)
    # Check questions answered in progress bar:
    # - `@total_initial_questions - num_removed_answers` accounts for the now hidden (but not deleted) questions
    expect(page).to have_text("#{expected_num_answers}/#{@total_initial_questions - num_removed_answers} answered")
  end

  def question_and_answer_counts_for_plan
    plan = Plan.includes(:questions, :answers).first
    [plan.questions.count, plan.answers.count]
  end

  def go_to_write_plan_page_and_verify_answered
    visit overview_plan_path(@plan)

    click_link 'Write Plan'

    # Expand all sections
    find('a[data-toggle-direction=show]').click

    # Check questions answered in progress bar.
    num_questions, num_answers = question_and_answer_counts_for_plan
    expect(page).to have_text("#{num_answers}/#{num_questions} answered")
  end

  def check_remove_data_effect_on_answer_form_selectors(remove_data)
    @all_questions_ids.each do |question_id|
      if remove_data.include?(question_id)
        expect(page).to have_no_selector("#answer-form-#{question_id}")
      else
        expect(page).to have_selector("#answer-form-#{question_id}")
      end
    end
  end

  # Checks for 'Saving' and 'Answered just now' messages
  def check_answer_save_statuses(answer_id)
    within("#answer-status-#{answer_id}") do
      saving_span = find('span.status[data-status="saving"]')
      expect(saving_span.text).to include('Saving')
      # We use `first()` because there are multiple span elements with `saved-at` status
      saved_span = first('span.status[data-status="saved-at"]')
      expect(saved_span.text).to include('Answered just now')
    end
  end

  def answer_conditional_question(question_option, question_type, check_type = 'check')
    case question_type
    when :checkbox
      # if it is a checkbox question, we need to know check_type as well ('check' vs 'uncheck')
      if check_type == 'check'
        check question_option.text
      else
        uncheck question_option.text
      end
    when :radiobutton
      choose question_option.text
    when :dropdown
      select(question_option.text, from: 'answer_question_option_ids')
    end
  end

  def determine_question_option(original_question, new_question, question_type)
    # If :checkbox question, we want to return the original question to be unchecked
    return original_question if question_type == :checkbox

    # Else we want to return a different question to be selected via :radiobutton or :dropdown
    new_question
  end
end
