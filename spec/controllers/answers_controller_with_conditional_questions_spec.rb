# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  include RolesHelper

  before(:each) do
    template = create(:template, phases: 1, sections: 3)
    # 3 sections for ensuring that conditions involve questions in different sections.
    @section1, @section2, @section3 = template.sections

    # Different types of questions (than can have conditional options)
    @conditional_questions = create_conditional_questions

    # Questions that do not have conditional options for adding or removing
    @non_conditional_questions = create_non_conditional_questions

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
          condition = create(:condition, question: @conditional_questions[:checkbox],
                                         option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                         action_type: 'remove',
                                         remove_data: non_conditional_questions_ids_by_index(5))

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

          #  Check Answers in database (persisted). Expect removed answers to be destroyed.
          # Answers destroyed eare easier checked using array of ids rather than individually as in example
          # expect(Answer.exists?(@answers[:textarea][5].id)).to be_falsey.
          removed_answers = @answers.map { |_, answers| answers[5].id }
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
                             remove_data: non_conditional_questions_ids_by_index(3))

          create(:condition, question: @conditional_questions[:checkbox],
                             option_list: [@conditional_questions[:checkbox].question_options[4].id],
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
                                          option_list: [@conditional_questions[:checkbox].question_options[2].id],
                                          action_type: 'remove',
                                          remove_data: non_conditional_questions_ids_by_index(0))

          condition2 = create(:condition, question: @conditional_questions[:checkbox],
                                          option_list: [@conditional_questions[:checkbox].question_options[4].id],
                                          action_type: 'remove',
                                          remove_data: non_conditional_questions_ids_by_index(3))

          # We choose options that is in the option_list of the conditions defined above as well as an option
          # with no condition defined.
          args = {
            question_option_ids: [@conditional_questions[:checkbox].question_options[1].id,
                                  @conditional_questions[:checkbox].question_options[2].id,
                                  @conditional_questions[:checkbox].question_options[4].id],
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
                                         remove_data: non_conditional_questions_ids_by_index(5))

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
                             remove_data: non_conditional_questions_ids_by_index(3))

          create(:condition, question: @conditional_questions[:radiobutton],
                             option_list: [@conditional_questions[:radiobutton].question_options[4].id],
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
                                         remove_data: non_conditional_questions_ids_by_index(5))

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
                             remove_data: non_conditional_questions_ids_by_index(3))

          create(:condition, question: @conditional_questions[:dropdown],
                             option_list: [@conditional_questions[:dropdown].question_options[4].id],
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
                                       option_list: [@conditional_questions[:checkbox].question_options[2].id])

        condition2 = create(:condition, question: @conditional_questions[:checkbox],
                                        option_list: [@conditional_questions[:checkbox].question_options[4].id],
                                        action_type: 'remove',
                                        remove_data: non_conditional_questions_ids_by_index(3))

        #  We chose an option that is in the option_list of the condition defined above. Note that
        # the text sent by UI is an empty string.
        args = {
          text: '',
          question_option_ids: [@conditional_questions[:checkbox].question_options[2].id,
                                @conditional_questions[:checkbox].question_options[4].id,
                                @conditional_questions[:checkbox].question_options[1].id],
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

  private

  def create_conditional_questions
    {
      checkbox: create(:question, :checkbox, section: @section1, options: 5),
      radiobutton: create(:question, :radiobuttons, section: @section2, options: 5),
      dropdown: create(:question, :dropdown, section: @section3, options: 5)
    }
  end

  def create_non_conditional_questions
    {
      textarea: create_list(:question, 7, :textarea, section: @section1),
      textfield: create_list(:question, 7, :textfield, section: @section2),
      date: create_list(:question, 7, :date, section: @section3),
      rda_metadata: create_list(:question, 7, :rda_metadata, section: @section1, options: 3),
      checkbox: create_list(:question, 7, :checkbox, section: @section2, options: 3),
      radiobutton: create_list(:question, 7, :radiobuttons, section: @section3, options: 3),
      dropdown: create_list(:question, 7, :dropdown, section: @section1, options: 3),
      multiselectbox: create_list(:question, 7, :multiselectbox, section: @section2, options: 3)
    }
  end

  def non_conditional_questions_ids_by_index(index)
    @non_conditional_questions.map { |_, questions| questions[index].id }
  end

  def create_answers
    question_types_with_question_options = %i[checkbox radiobutton dropdown multiselectbox]
    answers = {}
    @non_conditional_questions.each do |question_type, questions|
      answers[question_type] = questions.map do |question|
        if question_types_with_question_options.include?(question_type)
          create(:answer, plan: @plan, question: question, question_options: [question.question_options[2]], user: @user)
        else
          create(:answer, plan: @plan, question: question, user: @user)
        end
      end
    end
    answers
  end

  def check_delivered_mail_for_webhook_data_and_question_data(webhook_data, question_type)
    ActionMailer::Base.deliveries.first do |mail|
      expect(mail.to).to eq([webhook_data['email']])
      expect(mail.subject).to eq(webhook_data['subject'])
      expect(mail.body.encoded).to include(webhook_data['message'])
      # To see structure of email sent see app/views/user_mailer/question_answered.html.erb.

      # Message should have @user.name, chosen option text and question text.
      expect(mail.body.encoded).to include(@user.name)
      expect(mail.body.encoded).to include(@conditional_questions[question_type].question_options[2].text)
      expect(mail.body.encoded).to include(@conditional_questions[question_type].text)
    end
  end

  def check_question_ids_to_show_and_hide(json, question_ids_to_hide = [])
    expect(json[:qn_data][:to_show]).to match_array(@all_questions_ids - question_ids_to_hide)
    expect(json[:qn_data][:to_hide]).to match_array(question_ids_to_hide)
  end
end
