# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  include RolesHelper

  before(:each) do
    template = create(:template, phases: 1, sections: 1)
    @section = template.sections.first

    # Different types of questions (than can have conditional options)
    @checkbox_conditional_question = create(:question, :checkbox, section: @section, options: 5)
    @radiobutton_conditional_question = create(:question, :radiobuttons, section: @section, options: 5)
    @dropdown_conditional_question = create(:question, :dropdown, section: @section, options: 5)

    @conditional_questions = [@checkbox_conditional_question, @radiobutton_conditional_question,
                              @dropdown_conditional_question]

    # Questions that do not have conditional options for adding or removing
    @textarea_questions = create_list(:question, 7, :textarea, section: @section)
    @textfield_questions = create_list(:question, 7, :textfield, section: @section)
    @date_questions = create_list(:question, 7, :date, section: @section)
    @rda_metadata_questions = create_list(:question, 7, :rda_metadata, section: @section, options: 3)
    @checkbox_questions = create_list(:question, 7, :checkbox, section: @section, options: 3)
    @radiobuttons_questions = create_list(:question, 7, :radiobuttons, section: @section, options: 3)
    @dropdown_questions = create_list(:question, 7, :dropdown, section: @section, options: 3)
    @multiselectbox_questions = create_list(:question, 7, :multiselectbox, section: @section, options: 3)

    @plan = create(:plan, :creator, template: template)
    @user = @plan.owner

    # Answer the questions in List2
    @textarea_answers = @textarea_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end

    @textfield_answers = @textfield_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end

    @date_answers = @date_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end

    @rda_metadata_answers = @rda_metadata_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, user: @user)
    end

    @checkbox_answers = @checkbox_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end

    @radiobuttons_answers = @radiobuttons_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end

    @dropdown_answers = @dropdown_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end

    @multiselectbox_answers = @multiselectbox_questions.each.map do |question|
      create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
    end

    @all_questions_ids = (@conditional_questions + @textarea_questions + @textfield_questions +
                          @date_questions + @rda_metadata_questions +
                          @checkbox_questions + @radiobuttons_questions +
                          @dropdown_questions + @multiselectbox_questions).map(&:id)

    @all_answers_ids = (@textarea_answers + @textfield_answers +
                        @date_answers + @rda_metadata_answers +
                        @checkbox_answers + @radiobuttons_answers +
                        @dropdown_answers + @multiselectbox_answers).map(&:id)

    sign_in(@user)
  end

  # NOTE: Condition is only implemented for checkboxes, radio buttons and dropdowns. In these cases, currently
  # the option_list only takes one option in the UI.
  # As functionality for more than option per condition does not yet exist in code.
  #  So all Conditions are created with option_list with a single option id.

  describe 'AnswersController#create_or_update for action_type: remove' do
    describe 'POST /answers/create_or_update (where atleast one question has one or more conditional options)' do
      # NOTE: checkbox, radiobuttons and dropdowns are the only question types that have conditional options

      # NOTE: Checkboxes allow for multiple options to be selected.
      context 'with conditional checkbox question' do
        it 'handles single option (with condition) in option_list ' do
          condition = create(:condition, question: @checkbox_conditional_question,
                                         option_list: [@checkbox_conditional_question.question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: [@textarea_questions[5].id, @textfield_questions[5].id,
                                                       @date_questions[5].id, @rda_metadata_questions[5].id,
                                                       @checkbox_questions[5].id, @radiobuttons_questions[5].id,
                                                       @dropdown_questions[5].id, @multiselectbox_questions[5].id])

          #  We chose an option that is in the option_list of the condition defined above. Note that
          # the text sent by UI is an empty string.
          args = {
            text: '',
            question_option_ids: [@checkbox_conditional_question.question_options[2].id],
            user_id: @user.id,
            question_id: @checkbox_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access

          # Check hide/show questions lists sent to frontend.
          expected_to_show_question_ids = @all_questions_ids - condition.remove_data
          expected_to_hide_question_ids = condition.remove_data
          expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
          expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)

          #  Check Answers in database (persisted). Expect removed answers to be destroyed.
          # Answers destroyed eare easier checked using array of ids rather than individually as in example
          # expect(Answer.exists?(@textarea_answers[5].id)).to be_falsey.
          removed_answers = [@textarea_answers[5].id, @textfield_answers[5].id,
                             @date_answers[5].id, @rda_metadata_answers[5].id, @checkbox_answers[5].id,
                             @radiobuttons_answers[5].id, @dropdown_answers[5].id, @multiselectbox_answers[5].id]
          expect(Answer.where(id: removed_answers).pluck(:id)).to be_empty
          # Answers left
          expect(Answer.where(id: @all_answers_ids).pluck(:id)).to match_array(
            @all_answers_ids - removed_answers
          )
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @checkbox_conditional_question,
                             option_list: [@checkbox_conditional_question.question_options[1].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[3].id, @textfield_questions[3].id,
                                           @date_questions[3].id, @rda_metadata_questions[3].id,
                                           @checkbox_questions[3].id, @dropdown_questions[3].id,
                                           @multiselectbox_questions[3].id])

          create(:condition, question: @checkbox_conditional_question,
                             option_list: [@checkbox_conditional_question.question_options[4].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                           @date_questions[0].id, @rda_metadata_questions[0].id,
                                           @checkbox_questions[0].id, @dropdown_questions[0].id,
                                           @multiselectbox_questions[0].id])

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@checkbox_conditional_question.question_options[0].id],
            user_id: @user.id,
            question_id: @checkbox_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:qn_data][:to_show]).to match_array(@all_questions_ids)
          expect(json[:qn_data][:to_hide]).to match_array([])
        end

        it 'handles multiple options (some with conditions) in option_list' do
          condition1 = create(:condition, question: @checkbox_conditional_question,
                                          option_list: [@checkbox_conditional_question.question_options[2].id],
                                          action_type: 'remove',
                                          remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                                        @date_questions[0].id, @rda_metadata_questions[0].id,
                                                        @checkbox_questions[0].id, @dropdown_questions[0].id,
                                                        @multiselectbox_questions[0].id])

          condition2 = create(:condition, question: @checkbox_conditional_question,
                                          option_list: [@checkbox_conditional_question.question_options[4].id],
                                          action_type: 'remove',
                                          remove_data: [@textarea_questions[3].id, @textfield_questions[3].id,
                                                        @date_questions[3].id, @rda_metadata_questions[3].id,
                                                        @checkbox_questions[3].id, @dropdown_questions[3].id,
                                                        @multiselectbox_questions[3].id])

          # We choose options that is in the option_list of the conditions defined above as well as an option
          # with no condition defined.
          args = {
            question_option_ids: [@checkbox_conditional_question.question_options[1].id,
                                  @checkbox_conditional_question.question_options[2].id,
                                  @checkbox_conditional_question.question_options[4].id],
            user_id: @user.id,
            question_id: @checkbox_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access

          expected_to_show_question_ids = @all_questions_ids - condition1.remove_data - condition2.remove_data
          expected_to_hide_question_ids = condition1.remove_data + condition2.remove_data
          expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
          expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)
        end
      end
      #  Note: radiobuttons only allow single selection.
      context 'with conditional radiobuttons question' do
        it 'handles single option (with condition) in option_list ' do
          condition = create(:condition, question: @radiobutton_conditional_question,
                                         option_list: [@radiobutton_conditional_question.question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: [@textarea_questions[5].id, @textfield_questions[5].id,
                                                       @date_questions[5].id, @rda_metadata_questions[5].id,
                                                       @checkbox_questions[5].id, @radiobuttons_questions[5].id,
                                                       @dropdown_questions[5].id, @multiselectbox_questions[5].id])

          # We choose an option that is in the option_list of the condition defined above.
          args = {
            text: '',
            question_option_ids: [@radiobutton_conditional_question.question_options[2].id],
            user_id: @user.id,
            question_id: @radiobutton_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          expected_to_show_question_ids = @all_questions_ids - condition.remove_data
          expected_to_hide_question_ids = condition.remove_data
          expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
          expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @radiobutton_conditional_question,
                             option_list: [@radiobutton_conditional_question.question_options[1].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[3].id, @textfield_questions[3].id,
                                           @date_questions[3].id, @rda_metadata_questions[3].id,
                                           @checkbox_questions[3].id, @dropdown_questions[3].id,
                                           @multiselectbox_questions[3].id])

          create(:condition, question: @radiobutton_conditional_question,
                             option_list: [@radiobutton_conditional_question.question_options[4].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                           @date_questions[0].id, @rda_metadata_questions[0].id,
                                           @checkbox_questions[0].id, @dropdown_questions[0].id,
                                           @multiselectbox_questions[0].id])

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@radiobutton_conditional_question.question_options[0].id],
            user_id: @user.id,
            question_id: @radiobutton_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:qn_data][:to_show]).to match_array(@all_questions_ids)
          expect(json[:qn_data][:to_hide]).to match_array([])
        end
      end

      # NOTE: dropdowns only allow single selection.
      context 'with conditional dropdown question' do
        it 'handles single option (with condition) in option_list ' do
          condition = create(:condition, question: @dropdown_conditional_question,
                                         option_list: [@dropdown_conditional_question.question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: [@textarea_questions[5].id, @textfield_questions[5].id,
                                                       @date_questions[5].id, @rda_metadata_questions[5].id,
                                                       @checkbox_questions[5].id, @radiobuttons_questions[5].id,
                                                       @dropdown_questions[5].id, @multiselectbox_questions[5].id])

          #  We chose an option that is in the option_list of the condition defined above.
          args = {
            text: @dropdown_conditional_question.question_options[2].text,
            question_option_ids: [@dropdown_conditional_question.question_options[2].id],
            user_id: @user.id,
            question_id: @dropdown_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          expected_to_show_question_ids = @all_questions_ids - condition.remove_data
          expected_to_hide_question_ids = condition.remove_data
          expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
          expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @dropdown_conditional_question,
                             option_list: [@dropdown_conditional_question.question_options[1].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[3].id, @textfield_questions[3].id,
                                           @date_questions[3].id, @rda_metadata_questions[3].id,
                                           @checkbox_questions[3].id, @dropdown_questions[3].id,
                                           @multiselectbox_questions[3].id])

          create(:condition, question: @dropdown_conditional_question,
                             option_list: [@dropdown_conditional_question.question_options[4].id],
                             action_type: 'remove',
                             remove_data: [@textarea_questions[0].id, @textfield_questions[0].id,
                                           @date_questions[0].id, @rda_metadata_questions[0].id,
                                           @checkbox_questions[0].id, @dropdown_questions[0].id,
                                           @multiselectbox_questions[0].id])

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@dropdown_conditional_question.question_options[0].id],
            user_id: @user.id,
            question_id: @dropdown_conditional_question.id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          expect(json[:qn_data][:to_show]).to match_array(@all_questions_ids)
          expect(json[:qn_data][:to_hide]).to match_array([])
        end
      end
    end
  end

  describe 'AnswersController#create_or_update for action_type: add_webhook' do
    before(:each) do
      ActionMailer::Base.deliveries = []
    end
    describe 'POST /answers/create_or_update (with add_webhook conditional option)' do
      # NOTE: checkbox, radiobuttons and dropdowns are the only question types
      # that have conditional options.
      it 'handles a checkbox option (with add_webhook condition)' do
        add_webhook_condition = create(
          :condition, :webhook,
          question: @checkbox_conditional_question,
          option_list: [@checkbox_conditional_question.question_options[2].id]
        )
        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@checkbox_conditional_question.question_options[2].id],
          user_id: @user.id,
          question_id: @checkbox_conditional_question.id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        expected_to_show_question_ids = @all_questions_ids - add_webhook_condition.remove_data
        expected_to_hide_question_ids = add_webhook_condition.remove_data
        expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
        expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)

        ActionMailer::Base.deliveries.first do |mail|
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
      it 'handles multiple checkbox options (one of which is add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @checkbox_conditional_question,
                                       option_list: [@checkbox_conditional_question.question_options[2].id])

        condition2 = create(:condition, question: @checkbox_conditional_question,
                                        option_list: [@checkbox_conditional_question.question_options[4].id],
                                        action_type: 'remove',
                                        remove_data: [@textarea_questions[3].id, @textfield_questions[3].id,
                                                      @date_questions[3].id, @rda_metadata_questions[3].id,
                                                      @checkbox_questions[3].id, @dropdown_questions[3].id,
                                                      @multiselectbox_questions[3].id])

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@checkbox_conditional_question.question_options[2].id,
                                @checkbox_conditional_question.question_options[4].id,
                                @checkbox_conditional_question.question_options[1].id],
          user_id: @user.id,
          question_id: @checkbox_conditional_question.id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        removed_data = add_webhook_condition.remove_data + condition2.remove_data
        expected_to_show_question_ids = @all_questions_ids - removed_data
        expected_to_hide_question_ids = add_webhook_condition.remove_data + condition2.remove_data
        expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
        expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)

        ActionMailer::Base.deliveries.first do |mail|
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

      it 'handles selection of a dropdown option (with add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @dropdown_conditional_question,
                                       option_list: [@dropdown_conditional_question.question_options[2].id])

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@dropdown_conditional_question.question_options[2].id],
          user_id: @user.id,
          question_id: @dropdown_conditional_question.id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        expected_to_show_question_ids = @all_questions_ids - add_webhook_condition.remove_data
        expected_to_hide_question_ids = add_webhook_condition.remove_data
        expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
        expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)

        ActionMailer::Base.deliveries.first do |mail|
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

      it 'handles selection of a radiobutton option (with add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @radiobutton_conditional_question,
                                       option_list: [@radiobutton_conditional_question.question_options[2].id])

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@radiobutton_conditional_question.question_options[2].id],
          user_id: @user.id,
          question_id: @radiobutton_conditional_question.id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        expected_to_show_question_ids = @all_questions_ids - add_webhook_condition.remove_data
        expected_to_hide_question_ids = add_webhook_condition.remove_data
        expect(json[:qn_data][:to_show]).to match_array(expected_to_show_question_ids)
        expect(json[:qn_data][:to_hide]).to match_array(expected_to_hide_question_ids)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)

        ActionMailer::Base.deliveries.first do |mail|
          expect(mail.to).to eq([webhook_data['email']])
          expect(mail.subject).to eq(webhook_data['subject'])
          expect(mail.body.encoded).to include(webhook_data['message'])
          # To see structure of email sent see app/views/user_mailer/question_answered.html.erb.

          # Message should have @user.name, chosen option text and question text.
          expect(mail.body.encoded).to include(@user.name)
          expect(mail.body.encoded).to include(@radiobutton_conditional_question.question_options[2].text)
          expect(mail.body.encoded).to include(@radiobutton_conditional_question.text)
        end
      end
    end
  end
end
