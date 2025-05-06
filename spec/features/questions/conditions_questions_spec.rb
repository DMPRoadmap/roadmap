# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Question::Conditions questions', type: :feature do
  include ConditionalQuestionsHelper
  before(:each) do
    @user = create(:user)
    @template = create(:template, :default, :published)
    @plan = create(:plan, :creator, template: @template)
    @phase = create(:phase, template: @template)
    # 3 sections for ensuring that conditions involve questions in different sections.
    @section1 = create(:section, phase: @phase)
    @section2 = create(:section, phase: @phase)
    @section3 = create(:section, phase: @phase)

    # Different types of questions (than can have conditional options)
    @conditional_questions = create_conditional_questions(5)

    # Questions that do not have conditional options for adding or removing
    @non_conditional_questions = create_non_conditional_questions(3, 5)

    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)

    @all_questions_ids = (@conditional_questions.values + @non_conditional_questions.values.flatten).map(&:id)

    # Answer the non-conditional questions
    create_answers

    sign_in(@user)

    # Ensure mailer box empty before test.
    ActionMailer::Base.deliveries = []
  end

  # NOTE: Condition is only implemented for checkboxes, radio buttons and dropdowns. In these cases, currently
  # the option_list only takes one option in the UI.
  # As functionality for more than option per condition does not yet exist in code.
  #  So all Conditions are created with option_list with a single option id.

  describe 'conditions with action_type remove' do
    feature 'User answers a checkboxes question with a condition' do
      scenario 'User answers chooses checkbox option with a condition', :js do
        condition = create(:condition, question: @conditional_questions[:checkbox],
                                       option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@non_conditional_questions[:textarea][0].id,
                                                     @non_conditional_questions[:textfield][1].id,
                                                     @non_conditional_questions[:date][2].id,
                                                     @non_conditional_questions[:rda_metadata][0].id,
                                                     @non_conditional_questions[:checkbox][1].id,
                                                     @non_conditional_questions[:radiobutton][2].id,
                                                     @non_conditional_questions[:dropdown][0].id,
                                                     @non_conditional_questions[:multiselectbox][1].id])

        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the checkbox_conditional_question.
        within("#answer-form-#{@conditional_questions[:checkbox].id}") do
          check @conditional_questions[:checkbox].question_options[2].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('17/19 answered')

        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now uncheck checkbox_conditional_question answer.
        within("#answer-form-#{@conditional_questions[:checkbox].id}") do
          uncheck @conditional_questions[:checkbox].question_options[2].text
          click_button 'Save'
        end

        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # Also 1 answer should be removed as we unchecked  @conditional_questions[:checkbox].question_options[2].text
        # 17 (from previous check) - 1 = 16
        expect(page).to have_text('16/27 answered')
      end

      scenario 'User answers chooses checkbox option without a condition', :js do
        create(:condition, question: @conditional_questions[:checkbox],
                           option_list: [@conditional_questions[:checkbox].question_options[1].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(2))

        create(:condition, question: @conditional_questions[:checkbox],
                           option_list: [@conditional_questions[:checkbox].question_options[4].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(0))

        # We choose an option that is not in the option_list of the conditions defined above.
        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the checkbox_conditional_question
        within("#answer-form-#{@conditional_questions[:checkbox].id}") do
          check @conditional_questions[:checkbox].question_options[0].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        # Check questions answered in progress bar.
        expect(page).to have_text('25/27 answered')
      end
    end

    feature 'User answers a radiobutton question with a condition' do
      scenario 'User answers selects radiobutton option with a condition', :js do
        condition = create(:condition, question: @conditional_questions[:radiobutton],
                                       option_list: [@conditional_questions[:radiobutton].question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@non_conditional_questions[:textarea][0].id,
                                                     @non_conditional_questions[:textfield][1].id,
                                                     @non_conditional_questions[:date][2].id,
                                                     @non_conditional_questions[:rda_metadata][0].id,
                                                     @non_conditional_questions[:checkbox][1].id,
                                                     @non_conditional_questions[:radiobutton][2].id,
                                                     @non_conditional_questions[:dropdown][0].id,
                                                     @non_conditional_questions[:multiselectbox][1].id])

        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the radiobutton_conditional_question.
        within("#answer-form-#{@conditional_questions[:radiobutton].id}") do
          choose @conditional_questions[:radiobutton].question_options[2].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        # Check questions answered in progress bar.
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('17/19 answered')
        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now for radiobutton_conditional_question answer, there in no unchoose option,
        # so we switch options to a different option without any conditions.
        within("#answer-form-#{@conditional_questions[:radiobutton].id}") do
          choose @conditional_questions[:radiobutton].question_options[0].text
          click_button 'Save'
        end

        # Check questions answered in progress bar.
        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # Also 1 answer should be removed as we unchecked  @conditional_questions[:radiobutton].question_options[2].text
        # 17 (from previous check) - 1 = 16
        expect(page).to have_text('17/27 answered')
      end

      scenario 'User answers selects radiobutton option without a condition', :js do
        create(:condition, question: @conditional_questions[:radiobutton],
                           option_list: [@conditional_questions[:radiobutton].question_options[1].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(2))

        create(:condition, question: @conditional_questions[:radiobutton],
                           option_list: [@conditional_questions[:radiobutton].question_options[4].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(0))

        # We choose an option that is not in the option_list of the conditions defined above.
        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the radiobutton_conditional_question.
        within("#answer-form-#{@conditional_questions[:radiobutton].id}") do
          choose @conditional_questions[:radiobutton].question_options[0].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        # Check questions answered in progress bar.
        expect(page).to have_text('25/27 answered')
      end
    end

    feature 'User answers a dropdown question with a condition' do
      scenario 'User answers chooses dropdown option with a condition', :js do
        condition = create(:condition, question: @conditional_questions[:dropdown],
                                       option_list: [@conditional_questions[:dropdown].question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@non_conditional_questions[:textarea][0].id,
                                                     @non_conditional_questions[:textfield][1].id,
                                                     @non_conditional_questions[:date][2].id,
                                                     @non_conditional_questions[:rda_metadata][0].id,
                                                     @non_conditional_questions[:checkbox][1].id,
                                                     @non_conditional_questions[:radiobutton][2].id,
                                                     @non_conditional_questions[:dropdown][0].id,
                                                     @non_conditional_questions[:multiselectbox][1].id])

        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the dropdown_conditional_question
        within("#answer-form-#{@conditional_questions[:dropdown].id}") do
          select(@conditional_questions[:dropdown].question_options[2].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        # Check questions answered in progress bar.
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('17/19 answered')
        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now select another option for dropdown_conditional_question.
        within("#answer-form-#{@conditional_questions[:dropdown].id}") do
          select(@conditional_questions[:dropdown].question_options[1].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        # Check questions answered in progress bar.
        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # 17 (from previous check as we switched answer from same dropdown)
        expect(page).to have_text('17/27 answered')
      end

      scenario 'User answers select dropdown option without a condition', :js do
        create(:condition, question: @conditional_questions[:dropdown],
                           option_list: [@conditional_questions[:dropdown].question_options[1].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(2))

        create(:condition, question: @conditional_questions[:dropdown],
                           option_list: [@conditional_questions[:dropdown].question_options[4].id],
                           action_type: 'remove',
                           remove_data: non_conditional_questions_ids_by_index(0))
        visit overview_plan_path(@plan)

        click_link 'Write Plan'

        # Expand all sections
        find('a[data-toggle-direction=show]').click

        # Check questions answered in progress bar.
        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('24/27 answered')

        # Answer the dropdown_conditional_question.
        within("#answer-form-#{@conditional_questions[:dropdown].id}") do
          select(@conditional_questions[:dropdown].question_options[0].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        # Check questions answered in progress bar.
        expect(page).to have_text('25/27 answered')
      end
    end
  end
  describe 'conditions with action_type add_webhook' do
    scenario 'User answers chooses checkbox option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @conditional_questions[:checkbox],
                                               option_list: [@conditional_questions[:checkbox].question_options[2].id])

      visit overview_plan_path(@plan)

      click_link 'Write Plan'

      # Expand all sections
      find('a[data-toggle-direction=show]').click

      # Check questions answered in progress bar.
      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('24/27 answered')

      # Answer the checkbox_conditional_question.
      within("#answer-form-#{@conditional_questions[:checkbox].id}") do
        check @conditional_questions[:checkbox].question_options[2].text
      end

      expect(page).to have_text('Answered just now')

      # Check questions answered in progress bar.
      # Expect one extra answer to be added.
      expect(page).to have_text('25/27 answered')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :checkbox)
    end

    scenario 'User answers chooses radiobutton option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @conditional_questions[:radiobutton],
                                               option_list: [@conditional_questions[:radiobutton].question_options[0].id])

      visit overview_plan_path(@plan)

      click_link 'Write Plan'

      # Expand all sections
      find('a[data-toggle-direction=show]').click

      # Check questions answered in progress bar.
      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('24/27 answered')

      # Now for radiobutton_conditional_question answer, there in no unchoose option,
      # so we switch options to a different option without any conditions.
      within("#answer-form-#{@conditional_questions[:radiobutton].id}") do
        choose @conditional_questions[:radiobutton].question_options[0].text
      end

      expect(page).to have_text('Answered just now')

      # Check questions answered in progress bar.
      # Expect one extra answer to be added.
      expect(page).to have_text('25/27 answered')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :radiobutton)
    end

    scenario 'User answers chooses dropdown option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @conditional_questions[:dropdown],
                                               option_list: [@conditional_questions[:dropdown].question_options[2].id])

      visit overview_plan_path(@plan)

      click_link 'Write Plan'

      # Expand all sections
      find('a[data-toggle-direction=show]').click

      # Check questions answered in progress bar.
      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('24/27 answered')

      # Answer the dropdown_conditional_question
      within("#answer-form-#{@conditional_questions[:dropdown].id}") do
        select(@conditional_questions[:dropdown].question_options[2].text, from: 'answer_question_option_ids')
      end

      expect(page).to have_text('Answered just now')

      # Check questions answered in progress bar.
      # Expect one extra answer to be added.
      expect(page).to have_text('25/27 answered')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :dropdown)
    end
  end
end
