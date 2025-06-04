# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  include RolesHelper
  include ConditionalQuestionsHelper

  before(:each) do
    template = create(:template, phases: 1, sections: 3)
    # 3 sections for ensuring that conditions involve questions in different sections.
    @section1, @section2, @section3 = template.sections

    # Different types of questions (than can have conditional options)
    @conditional_questions = create_conditional_questions(3)

    # Questions that do not have conditional options for adding or removing
    @non_conditional_questions = create_non_conditional_questions(3, 3)

    @plan = create(:plan, :creator, template: template)
    @user = @plan.owner

    # Answer the questions in List2
    @answers = create_answers

    @all_questions_ids = (@conditional_questions.values + @non_conditional_questions.values.flatten).map(&:id)
    @all_answers_ids = @answers.values.flatten.map(&:id)

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
          non_conditional_question_index = 0
          condition = create(:condition, question: @conditional_questions[:checkbox],
                                         option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: non_conditional_questions_ids_by_index(non_conditional_question_index))

          #  We chose an option that is in the option_list of the condition defined above. Note that
          # the text sent by UI is an empty string.
          args = {
            text: '',
            question_option_ids: [@conditional_questions[:checkbox].question_options[2].id],
            user_id: @user.id,
            question_id: @conditional_questions[:checkbox].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access

          # Check hide/show questions lists sent to frontend.
          check_question_ids_to_show_and_hide(json, condition.remove_data)

          # Verify that answers for the `removed_data` questions were deleted from the DB.
          # NOTE: `@answers` contains only answers to non-conditional questions.
          #       So we use `non_conditional_question_index` to locate the corresponding answer
          #       for each type of non-conditional question.
          removed_answers = @answers.map { |_, answers| answers[non_conditional_question_index].id }
          expect(Answer.where(id: removed_answers).pluck(:id)).to be_empty
          # Answers left
          expect(Answer.where(id: @all_answers_ids).pluck(:id)).to match_array(
            @all_answers_ids - removed_answers
          )
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @conditional_questions[:checkbox],
                             option_list: [@conditional_questions[:checkbox].question_options[1].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(2))

          create(:condition, question: @conditional_questions[:checkbox],
                             option_list: [@conditional_questions[:checkbox].question_options[2].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(0))

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@conditional_questions[:checkbox].question_options[0].id],
            user_id: @user.id,
            question_id: @conditional_questions[:checkbox].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          check_question_ids_to_show_and_hide(json)
        end

        it 'handles multiple options (some with conditions) in option_list' do
          condition1 = create(:condition, question: @conditional_questions[:checkbox],
                                          option_list: [@conditional_questions[:checkbox].question_options[1].id],
                                          action_type: 'remove',
                                          remove_data: non_conditional_questions_ids_by_index(0))

          condition2 = create(:condition, question: @conditional_questions[:checkbox],
                                          option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                          action_type: 'remove',
                                          remove_data: non_conditional_questions_ids_by_index(2))

          # We choose options that is in the option_list of the conditions defined above as well as an option
          # with no condition defined.
          args = {
            question_option_ids: [@conditional_questions[:checkbox].question_options[0].id,
                                  @conditional_questions[:checkbox].question_options[1].id,
                                  @conditional_questions[:checkbox].question_options[2].id],
            user_id: @user.id,
            question_id: @conditional_questions[:checkbox].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          remove_data = condition1.remove_data + condition2.remove_data
          check_question_ids_to_show_and_hide(json, remove_data)
        end
      end
      #  Note: radiobuttons only allow single selection.
      context 'with conditional radiobuttons question' do
        it 'handles single option (with condition) in option_list ' do
          condition = create(:condition, question: @conditional_questions[:radiobutton],
                                         option_list: [@conditional_questions[:radiobutton].question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: non_conditional_questions_ids_by_index(2))

          # We choose an option that is in the option_list of the condition defined above.
          args = {
            text: '',
            question_option_ids: [@conditional_questions[:radiobutton].question_options[2].id],
            user_id: @user.id,
            question_id: @conditional_questions[:radiobutton].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          check_question_ids_to_show_and_hide(json, condition.remove_data)
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @conditional_questions[:radiobutton],
                             option_list: [@conditional_questions[:radiobutton].question_options[1].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(2))

          create(:condition, question: @conditional_questions[:radiobutton],
                             option_list: [@conditional_questions[:radiobutton].question_options[2].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(0))

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@conditional_questions[:radiobutton].question_options[0].id],
            user_id: @user.id,
            question_id: @conditional_questions[:radiobutton].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          check_question_ids_to_show_and_hide(json)
        end
      end

      # NOTE: dropdowns only allow single selection.
      context 'with conditional dropdown question' do
        it 'handles single option (with condition) in option_list ' do
          condition = create(:condition, question: @conditional_questions[:dropdown],
                                         option_list: [@conditional_questions[:dropdown].question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: non_conditional_questions_ids_by_index(2))

          #  We chose an option that is in the option_list of the condition defined above.
          args = {
            text: @conditional_questions[:dropdown].question_options[2].text,
            question_option_ids: [@conditional_questions[:dropdown].question_options[2].id],
            user_id: @user.id,
            question_id: @conditional_questions[:dropdown].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          check_question_ids_to_show_and_hide(json, condition.remove_data)
        end
        it 'handles single option (without condition) in option_list' do
          create(:condition, question: @conditional_questions[:dropdown],
                             option_list: [@conditional_questions[:dropdown].question_options[1].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(2))

          create(:condition, question: @conditional_questions[:dropdown],
                             option_list: [@conditional_questions[:dropdown].question_options[2].id],
                             action_type: 'remove',
                             remove_data: non_conditional_questions_ids_by_index(0))

          # We choose an option that is not in the option_list of the conditions defined above.
          args = {
            text: '',
            question_option_ids: [@conditional_questions[:dropdown].question_options[0].id],
            user_id: @user.id,
            question_id: @conditional_questions[:dropdown].id,
            plan_id: @plan.id,
            lock_version: 0
          }

          post :create_or_update, params: { answer: args }

          json = JSON.parse(response.body).with_indifferent_access
          check_question_ids_to_show_and_hide(json)
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
          question: @conditional_questions[:checkbox],
          option_list: [@conditional_questions[:checkbox].question_options[2].id]
        )
        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@conditional_questions[:checkbox].question_options[2].id],
          user_id: @user.id,
          question_id: @conditional_questions[:checkbox].id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access
        # Check hide/show questions lists sent to frontend.
        check_question_ids_to_show_and_hide(json, add_webhook_condition.remove_data)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)
        check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :checkbox)
      end
      it 'handles multiple checkbox options (one of which is add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @conditional_questions[:checkbox],
                                       option_list: [@conditional_questions[:checkbox].question_options[1].id])

        condition2 = create(:condition, question: @conditional_questions[:checkbox],
                                        option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                        action_type: 'remove',
                                        remove_data: non_conditional_questions_ids_by_index(2))

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@conditional_questions[:checkbox].question_options[0].id,
                                @conditional_questions[:checkbox].question_options[1].id,
                                @conditional_questions[:checkbox].question_options[2].id],
          user_id: @user.id,
          question_id: @conditional_questions[:checkbox].id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        remove_data = add_webhook_condition.remove_data + condition2.remove_data
        check_question_ids_to_show_and_hide(json, remove_data)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)
        check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :checkbox)
      end

      it 'handles selection of a dropdown option (with add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @conditional_questions[:dropdown],
                                       option_list: [@conditional_questions[:dropdown].question_options[2].id])

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@conditional_questions[:dropdown].question_options[2].id],
          user_id: @user.id,
          question_id: @conditional_questions[:dropdown].id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        check_question_ids_to_show_and_hide(json, add_webhook_condition.remove_data)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)
        check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :dropdown)
      end

      it 'handles selection of a radiobutton option (with add_webhook condition)' do
        add_webhook_condition = create(:condition,
                                       :webhook,
                                       question: @conditional_questions[:radiobutton],
                                       option_list: [@conditional_questions[:radiobutton].question_options[2].id])

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@conditional_questions[:radiobutton].question_options[2].id],
          user_id: @user.id,
          question_id: @conditional_questions[:radiobutton].id,
          plan_id: @plan.id,
          lock_version: 0
        }

        post :create_or_update, params: { answer: args }

        json = JSON.parse(response.body).with_indifferent_access

        # Check hide/show questions lists sent to frontend.
        check_question_ids_to_show_and_hide(json, add_webhook_condition.remove_data)

        # An email should have been sent to the configured recipient in the webhook.
        # The webhook_data is a Json string of form:
        # '{"name":"Joe Bloggs","email":"joe.bloggs@example.com","subject":"Large data volume","message":"A message."}'
        expect(ActionMailer::Base.deliveries.count).to eq(1)
        webhook_data = JSON.parse(add_webhook_condition.webhook_data)
        check_delivered_mail_for_webhook_data_and_question_data(webhook_data, :radiobutton)
      end
    end
  end
end
