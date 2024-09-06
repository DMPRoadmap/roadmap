# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Question::Conditions questions', type: :feature do
  before(:each) do
    @user = create(:user)
    @template = create(:template, :default, :published)
    @plan = create(:plan, :creator, template: @template)
    @phase = create(:phase, template: @template)
    @section = create(:section, phase: @phase)

    # Different types of questions (than can have conditional options)
    @checkbox_conditional_question = create(:question, :checkbox, section: @section, options: 5)
    @radiobutton_conditional_question = create(:question, :radiobuttons, section: @section, options: 5)
    @dropdown_conditional_question = create(:question, :dropdown, section: @section, options: 5)

    @conditional_questions = [@checkbox_conditional_question, @radiobutton_conditional_question,
                              @dropdown_conditional_question]

    # Questions that do not have conditional options for adding or removing
    @textarea_questions = create_list(:question, 3, :textarea, section: @section)
    @textfield_questions = create_list(:question, 3, :textfield, section: @section)
    @date_questions = create_list(:question, 3, :date, section: @section)
    @rda_metadata_questions = create_list(:question, 3, :rda_metadata, section: @section, options: 5)
    @checkbox_questions = create_list(:question, 3, :checkbox, section: @section, options: 5)
    @radiobuttons_questions = create_list(:question, 3, :radiobuttons, section: @section, options: 5)
    @dropdown_questions = create_list(:question, 3, :dropdown, section: @section, options: 5)
    @multiselectbox_questions = create_list(:question, 3, :multiselectbox, section: @section, options: 5)

    create(:role, :creator, :editor, :commenter, user: @user, plan: @plan)

    @all_questions_ids = (@conditional_questions + @textarea_questions + @textfield_questions +
                          @date_questions + @rda_metadata_questions +
                          @checkbox_questions + @radiobuttons_questions +
                          @dropdown_questions + @multiselectbox_questions).map(&:id)

    # Answer the non-conditional questions
    @textarea_answers = @textarea_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end

    @all_non_conditional_question_answers_ids = @textarea_answers.map(&:id)

    @textfield_answers = @textfield_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end
    @all_non_conditional_question_answers_ids += @textfield_answers.map(&:id)

    @date_answers = @date_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end
    @all_non_conditional_question_answers_ids += @date_answers.map(&:id)

    @rda_metadata_answers = @rda_metadata_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end
    @all_non_conditional_question_answers_ids += @rda_metadata_answers.map(&:id)

    @checkbox_answers = @checkbox_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end
    @all_non_conditional_question_answers_ids += @checkbox_answers.map(&:id)

    @radiobuttons_answers = @radiobuttons_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end
    @all_non_conditional_question_answers_ids += @radiobuttons_answers.map(&:id)

    @dropdown_answers = @dropdown_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end
    @all_non_conditional_question_answers_ids += @dropdown_answers.map(&:id)

    @multiselectbox_answers = @multiselectbox_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end
    @all_non_conditional_question_answers_ids += @multiselectbox_answers.map(&:id)

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
        condition = create(:condition, question: @checkbox_conditional_question,
                                       option_list: [@checkbox_conditional_question.question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@textarea_questions[0].id,
                                                     @textfield_questions[1].id,
                                                     @date_questions[2].id,
                                                     @rda_metadata_questions[0].id,
                                                     @checkbox_questions[1].id,
                                                     @radiobuttons_questions[2].id,
                                                     @dropdown_questions[0].id,
                                                     @multiselectbox_questions[1].id])

        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the checkbox_conditional_question.
        within("#answer-form-#{@checkbox_conditional_question.id}") do
          check @checkbox_conditional_question.question_options[2].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('(17 / 19)')
        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now uncheck checkbox_conditional_question answer.
        within("#answer-form-#{@checkbox_conditional_question.id}") do
          uncheck @checkbox_conditional_question.question_options[2].text
          click_button 'Save'
        end

        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # Also 1 answer should be removed as we unchecked  @checkbox_conditional_question.question_options[2].text
        # 17 (from previous check) - 1 = 16
        expect(page).to have_text('(16 / 27)')
      end

      scenario 'User answers chooses checkbox option without a condition', :js do
        create(:condition, question: @checkbox_conditional_question,
                           option_list: [@checkbox_conditional_question.question_options[1].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[2].id, @textfield_questions[2].id,
                                         @date_questions[2].id, @rda_metadata_questions[2].id, @checkbox_questions[2].id,
                                         @dropdown_questions[2].id, @multiselectbox_questions[2].id])

        create(:condition, question: @checkbox_conditional_question,
                           option_list: [@checkbox_conditional_question.question_options[4].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                         @date_questions[0].id, @rda_metadata_questions[0].id, @checkbox_questions[0].id,
                                         @dropdown_questions[0].id, @multiselectbox_questions[0].id])

        # We choose an option that is not in the option_list of the conditions defined above.
        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the checkbox_conditional_question
        within("#answer-form-#{@checkbox_conditional_question.id}") do
          check @checkbox_conditional_question.question_options[0].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        expect(page).to have_text('(25 / 27)')
      end
    end

    feature 'User answers a radiobutton question with a condition' do
      scenario 'User answers selects radiobutton option with a condition', :js do
        condition = create(:condition, question: @radiobutton_conditional_question,
                                       option_list: [@radiobutton_conditional_question.question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@textarea_questions[0].id,
                                                     @textfield_questions[1].id,
                                                     @date_questions[2].id,
                                                     @rda_metadata_questions[0].id,
                                                     @checkbox_questions[1].id,
                                                     @radiobuttons_questions[2].id,
                                                     @dropdown_questions[0].id,
                                                     @multiselectbox_questions[1].id])

        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the radiobutton_conditional_question.
        within("#answer-form-#{@radiobutton_conditional_question.id}") do
          choose @radiobutton_conditional_question.question_options[2].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('(17 / 19)')
        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now for radiobutton_conditional_question answer, there in no unchoose option,
        # so we switch options to a different option without any conditions.
        within("#answer-form-#{@radiobutton_conditional_question.id}") do
          choose @radiobutton_conditional_question.question_options[0].text
          click_button 'Save'
        end

        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # Also 1 answer should be removed as we unchecked  @radiobutton_conditional_question.question_options[2].text
        # 17 (from previous check) - 1 = 16
        expect(page).to have_text('(17 / 27)')
      end

      scenario 'User answers selects radiobutton option without a condition', :js do
        create(:condition, question: @radiobutton_conditional_question,
                           option_list: [@radiobutton_conditional_question.question_options[1].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[2].id, @textfield_questions[2].id,
                                         @date_questions[2].id, @rda_metadata_questions[2].id, @checkbox_questions[2].id,
                                         @dropdown_questions[2].id, @multiselectbox_questions[2].id])

        create(:condition, question: @radiobutton_conditional_question,
                           option_list: [@radiobutton_conditional_question.question_options[4].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                         @date_questions[0].id, @rda_metadata_questions[0].id, @checkbox_questions[0].id,
                                         @dropdown_questions[0].id, @multiselectbox_questions[0].id])

        # We choose an option that is not in the option_list of the conditions defined above.
        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the radiobutton_conditional_question.
        within("#answer-form-#{@radiobutton_conditional_question.id}") do
          choose @radiobutton_conditional_question.question_options[0].text
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        expect(page).to have_text('(25 / 27)')
      end
    end

    feature 'User answers a dropdown question with a condition' do
      scenario 'User answers chooses dropdown option with a condition', :js do
        condition = create(:condition, question: @dropdown_conditional_question,
                                       option_list: [@dropdown_conditional_question.question_options[2].id],
                                       action_type: 'remove',
                                       remove_data: [@textarea_questions[0].id,
                                                     @textfield_questions[1].id,
                                                     @date_questions[2].id,
                                                     @rda_metadata_questions[0].id,
                                                     @checkbox_questions[1].id,
                                                     @radiobuttons_questions[2].id,
                                                     @dropdown_questions[0].id,
                                                     @multiselectbox_questions[1].id])

        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the dropdown_conditional_question
        within("#answer-form-#{@dropdown_conditional_question.id}") do
          select(@dropdown_conditional_question.question_options[2].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')
        # Expect 8 questions and answers that have ids in condition.remove_data to be removed, and 1 new answer added:
        # 24 -8 + 1 = 17 (Answers left)
        # 27 - 8 = 19 (Questions left)
        expect(page).to have_text('(17 / 19)')
        condition.remove_data.each.map do |question_id|
          expect(page).to have_no_selector("#answer-form-#{question_id}")
        end

        expected_remaining_question_ids = @all_questions_ids - condition.remove_data

        expected_remaining_question_ids.each.map do |question_id|
          expect(page).to have_selector("#answer-form-#{question_id}")
        end

        # Now select another option for dropdown_conditional_question.
        within("#answer-form-#{@dropdown_conditional_question.id}") do
          select(@dropdown_conditional_question.question_options[1].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        # Expect 27 questions to appear again, but the 8 answers that were removed should not be there.
        # 17 (from previous check as we switched answer from same dropdown)
        expect(page).to have_text('(17 / 27)')
      end

      scenario 'User answers select dropdown option without a condition', :js do
        create(:condition, question: @dropdown_conditional_question,
                           option_list: [@dropdown_conditional_question.question_options[1].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[2].id, @textfield_questions[2].id,
                                         @date_questions[2].id, @rda_metadata_questions[2].id, @checkbox_questions[2].id,
                                         @dropdown_questions[2].id, @multiselectbox_questions[2].id])

        create(:condition, question: @dropdown_conditional_question,
                           option_list: [@dropdown_conditional_question.question_options[4].id],
                           action_type: 'remove',
                           remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                         @date_questions[0].id, @rda_metadata_questions[0].id, @checkbox_questions[0].id,
                                         @dropdown_questions[0].id, @multiselectbox_questions[0].id])
        visit overview_plan_path(@plan)

        click_link 'Write plan'

        find("#section-panel-#{@section.id}").click

        # 24 non-conditional questions in total  answered.
        expect(page).to have_text('(24 / 27)')

        # Answer the dropdown_conditional_question.
        within("#answer-form-#{@dropdown_conditional_question.id}") do
          select(@dropdown_conditional_question.question_options[0].text, from: 'answer_question_option_ids')
          click_button 'Save'
        end

        expect(page).to have_text('Answered just now')

        expect(page).to have_text('(25 / 27)')
      end
    end
  end
  describe 'conditions with action_type add_webhook' do

    scenario 'User answers chooses checkbox option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @checkbox_conditional_question,
                                               option_list: [@checkbox_conditional_question.question_options[2].id])

      visit overview_plan_path(@plan)

      click_link 'Write plan'

      find("#section-panel-#{@section.id}").click

      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('(24 / 27)')

      # Answer the checkbox_conditional_question.
      within("#answer-form-#{@checkbox_conditional_question.id}") do
        check @checkbox_conditional_question.question_options[2].text
      end

      expect(page).to have_text('Answered just now')
      # Expect one extra answer to be added.
      expect(page).to have_text('(25 / 27)')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      ActionMailer::Base.deliveries.last do |mail|
        expect(mail.to).to eq([webhook_data['email']])
        expect(mail.subject).to eq(webhook_data['subject'])
        expect(mail.body.encoded).to include(webhook_data['message'])
        # To see structure of email sent see app/views/user_mailer/question_answered.html.erb.
        # Message should have @user.name, chosen option text and question text.
        expect(mail.body.encoded).to include(@user.name)
        expect(mail.body.encoded).to include(@checkbox_conditional_question.question_options[2].text)
        expect(mail.body.encoded).to include(@checkbox_conditional_question.text)
      end
    end

    scenario 'User answers chooses radiobutton option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @radiobutton_conditional_question,
                                               option_list: [@radiobutton_conditional_question.question_options[0].id])

      visit overview_plan_path(@plan)

      click_link 'Write plan'

      find("#section-panel-#{@section.id}").click

      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('(24 / 27)')

      # Now for radiobutton_conditional_question answer, there in no unchoose option,
      # so we switch options to a different option without any conditions.
      within("#answer-form-#{@radiobutton_conditional_question.id}") do
        choose @radiobutton_conditional_question.question_options[0].text
      end

      expect(page).to have_text('Answered just now')
      # Expect one extra answer to be added.
      expect(page).to have_text('(25 / 27)')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      ActionMailer::Base.deliveries.last do |mail|
        expect(mail.to).to eq([webhook_data['email']])
        expect(mail.subject).to eq(webhook_data['subject'])
        expect(mail.body.encoded).to include(webhook_data['message'])
        # To see structure of email sent see app/views/user_mailer/question_answered.html.erb.
        # Message should have @user.name, chosen option text and question text.
        expect(mail.body.encoded).to include(@user.name)
        expect(mail.body.encoded).to include(@radiobutton_conditional_question.question_options[0].text)
        expect(mail.body.encoded).to include(@radiobutton_conditional_question.text)
      end
    end

    scenario 'User answers chooses dropdown option with a condition (with action_type: add_webhook)', :js do
      condition = create(:condition, :webhook, question: @dropdown_conditional_question,
                                               option_list: [@dropdown_conditional_question.question_options[2].id])

      visit overview_plan_path(@plan)

      click_link 'Write plan'

      find("#section-panel-#{@section.id}").click

      # 24 non-conditional questions in total  answered.
      expect(page).to have_text('(24 / 27)')

      # Answer the dropdown_conditional_question
      within("#answer-form-#{@dropdown_conditional_question.id}") do
        select(@dropdown_conditional_question.question_options[2].text, from: 'answer_question_option_ids')
      end

      expect(page).to have_text('Answered just now')
      # Expect one extra answer to be added.
      expect(page).to have_text('(25 / 27)')

      # An email should have been sent to the configured recipient in the webhook.
      # The webhook_data is a Json string of form:
      # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      webhook_data = JSON.parse(condition.webhook_data)

      ActionMailer::Base.deliveries.last do |mail|
        expect(mail.to).to eq([webhook_data['email']])
        expect(mail.subject).to eq(webhook_data['subject'])
        expect(mail.body.encoded).to include(webhook_data['message'])
        # To see structure of email sent see app/views/user_mailer/question_answered.html.erb.
        # Message should have @user.name, chosen option text and question text.
        expect(mail.body.encoded).to include(@user.name)
        expect(mail.body.encoded).to include(@dropdown_conditional_question.question_options[2].text)
        expect(mail.body.encoded).to include(@dropdown_conditional_question.text)
      end
    end
  end
end
