require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  include GlobalHelpers
  
  setup do
    @user = User.first
    
    tmplt = generate_complete_template
    @plan = Plan.create(project: Project.first, version: tmplt.phases.first.versions.first)
    
    @question = @plan.version.sections.first.questions.first
    
    @option = Option.create(question: @question, text: 'Test Option', number: 1)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Option.new.valid?
    assert_not Option.new(question: @question, text: 'Test').valid?, "expected the 'number' field to be required"
    assert_not Option.new(question: @question, number: 1).valid?, "expected the 'text' and 'number' field to be required"
    assert_not Option.new(text: 'Test', number: 1).valid?, "expected the 'question' and 'number' field to be required"

    # Ensure the bare minimum and complete versions are valid
    a = Option.new(question: @question, text: 'Test', number: 1)
    assert a.valid?, "expected the 'text', 'question' and 'number fields to be enough to create an Option! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s returns the text of the option warning" do
    assert_equal @option.text, @option.to_s, "expected the to_s method to return the text field"
  end

  # ---------------------------------------------------
  test "can CRUD Guidance" do
    obj = Option.create(question: @question, text: 'Test', number: 1)
    assert_not obj.id.nil?, "was expecting to be able to create a new Option! #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.text, "Was expecting to be able to update the text of the Option!"
  
    assert obj.destroy!, "Was unable to delete the Option!"
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    question = Question.new(text: 'Testing 123', section: Section.first, question_format: QuestionFormat.first)
    verify_belongs_to_relationship(@option, question)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with OptionWarnings" do
    ow = OptionWarning.new(text: 'Test', organisation: @user.organisation, option: @option)
    verify_has_many_relationship(@option, ow, @option.option_warnings.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Answers" do
    answer = Answer.new(user: @user, plan: @plan, question: @question, text: 'Testing new answer')
    verify_has_many_relationship(@option, answer, @option.answers.count)
  end
end