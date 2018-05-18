require 'test_helper'

class QuestionOptionTest < ActiveSupport::TestCase
  include GlobalHelpers
  
  setup do
    @user = User.first
    
    @question = QuestionFormat.find_by(option_based: true).questions.first
    
    @plan = Plan.create(title: 'Test Plan', template: @question.section.phase.template, visibility: :privately_visible)
    
    @option = QuestionOption.create(question: @question, text: 'Test QuestionOption', number: 1)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not QuestionOption.new.valid?
    assert_not QuestionOption.new(question: @question, text: 'Test').valid?, "expected the 'number' field to be required"
    assert_not QuestionOption.new(question: @question, number: 1).valid?, "expected the 'text' and 'number' field to be required"
    assert_not QuestionOption.new(text: 'Test', number: 1).valid?, "expected the 'question' and 'number' field to be required"

    # Ensure the bare minimum and complete versions are valid
    a = QuestionOption.new(question: @question, text: 'Test', number: 1)
    assert a.valid?, "expected the 'text', 'question' and 'number fields to be enough to create an QuestionOption! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "can CRUD Guidance" do
    obj = QuestionOption.create(question: @question, text: 'Test', number: 1)
    assert_not obj.id.nil?, "was expecting to be able to create a new QuestionOption! #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.text, "Was expecting to be able to update the text of the QuestionOption!"
  
    assert obj.destroy!, "Was unable to delete the QuestionOption!"
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    option = QuestionOption.new(text: 'Test', number: 1)
    verify_belongs_to_relationship(option, @question)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Answers" do
    answer = Answer.new(user: @user, plan: @plan, question: @question, text: 'Testing new answer',
                        question_options: [@question.question_options.first])
    verify_has_many_relationship(@option, answer, @option.answers.count)
  end
end