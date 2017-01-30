require 'test_helper'

class AnswerTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    @text_based_questions = QuestionFormat.joins(:questions).joins(:question_options)#.where("question_options.id IS NULL")
    #@option_based_questions = QuestionFormat.joins(:questions).includes(:question_options).where("question_options.id IS NOT NULL")

    puts @text_based_questions.inspect
    
    @text_area_question = QuestionFormat.find_by(title: 'Text Area').questions.first
    @text_field_question = QuestionFormat.find_by(title: 'Text Field').questions.first
    @radio_button_question = QuestionFormat.find_by(title: 'Radio Button').questions.first
    @check_box_question = QuestionFormat.find_by(title: 'Check Box').questions.first
    @select_box_question = QuestionFormat.find_by(title: 'Dropdown').questions.first
    @multi_select_box_question = QuestionFormat.find_by(title: 'Multi Select Box').questions.first
    @date_question = QuestionFormat.find_by(title: 'Date').questions.first
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Answer.new.valid?

    # Validate the creation of text based answers
    [].each do |q|
      assert_not Answer.new(user: @user, question: q, text: 'Testing').valid?, "expected the 'plan' field to be required for a #{q.question_format.class.name}"
      assert_not Answer.new(plan: @plan, question: q, text: 'Testing').valid?, "expected the 'user' field to be required for a #{q.question_format.class.name}"
      assert_not Answer.new(user: @user, plan: @plan, text: 'Testing').valid?, "expected the 'question' field to be required for a #{q.question_format.class.name}"
      assert_not Answer.new(user: @user, question: q, plan: @plan).valid?, "expected the 'text' field to be required  for a #{q.question_format.class.name}"

      # Ensure the bar minimum and complete versions are valid
      a = Answer.new(user: @user, plan: @plan, question: q, text: 'Testing')
      assert a.valid?, "expected the 'plan', 'user' and 'question' and 'text' fields to be enough to create an Answer for a #{q.question_format.class.name}! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    end

    # Validate the creation of option based answers (a selection is not required)
    [@radio_button_question, @check_box_question, @select_box_question, @multi_select_box_question].each do |q|
      assert_not Answer.new(user: @user, question: q).valid?, "expected the 'plan' field to be required for a #{q.question_format.class.name}"
      assert_not Answer.new(plan: @plan, question: q).valid?, "expected the 'user' field to be required for a #{q.question_format.class.name}"
      assert_not Answer.new(user: @user, plan: @plan).valid?, "expected the 'question' field to be required for a #{q.question_format.class.name}"
      
      # Ensure the bar minimum and complete versions are valid
      a = Answer.new(user: @user, plan: @plan, question: q)
      assert a.valid?, "expected the 'plan', 'user' and 'question' fields to be enough to create an Answer for a #{q.question_format.class.name}! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    end
    
  end
  
  # ---------------------------------------------------
  test "cannot have multiple answers to the same question within a plan" do
    Answer.create(user: @user, plan: @plan, question: @plan.question.first)

    assert_not Answer.new(user: @user, plan: @plan, question: @text_area_question, text: 'Another answer to the same question!').valid?, "expected to NOT be able to add an answer to a question that already has an answer!"
  end
  
  # ---------------------------------------------------
  test "can CRUD answers for text based questions" do
    [@text_area_question, @text_field_question].each do |q|
      answr = Answer.create(user: @user, plan: @plan, question: q, text: 'Tested ABC')
      assert_not answr.id.nil?, "was expecting to be able to create a new Answer for a #{q.question_format.title} question: #{answr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      answr.text = 'Testing an update'
      answr.save!
      answr.reload
      assert_equal 'Testing an update', answr.text, "Was expecting to be able to update the text of the Answer for a #{q.question_format.title} question!"
    
      assert answr.destroy!, "Was unable to delete the Answer for a #{q.question_format.title} question!"
    end
  end
    
end
