# frozen_string_literal: true

module ConditionalQuestionsHelper
  def create_conditional_questions(num_options)
    {
      checkbox: create(:question, :checkbox, section: @section1, options: num_options),
      radiobutton: create(:question, :radiobuttons, section: @section2, options: num_options),
      dropdown: create(:question, :dropdown, section: @section3, options: num_options)
    }
  end

  def create_non_conditional_questions(num_questions, num_options)
    {
      textarea: create_list(:question, num_questions, :textarea, section: @section1),
      textfield: create_list(:question, num_questions, :textfield, section: @section2),
      date: create_list(:question, num_questions, :date, section: @section3),
      rda_metadata: create_list(:question, num_questions, :rda_metadata, section: @section1, options: num_options),
      checkbox: create_list(:question, num_questions, :checkbox, section: @section2, options: num_options),
      radiobutton: create_list(:question, num_questions, :radiobuttons, section: @section3, options: num_options),
      dropdown: create_list(:question, num_questions, :dropdown, section: @section1, options: num_options),
      multiselectbox: create_list(:question, num_questions, :multiselectbox, section: @section2, options: num_options)
    }
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

  def non_conditional_questions_ids_by_index(index)
    @non_conditional_questions.map { |_, questions| questions[index].id }
  end

  def check_question_ids_to_show_and_hide(json, question_ids_to_hide = [])
    expect(json[:qn_data][:to_show]).to match_array(@all_questions_ids - question_ids_to_hide)
    expect(json[:qn_data][:to_hide]).to match_array(question_ids_to_hide)
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
end
