require 'test_helper'

class SuggestedAnswerTest < ActiveSupport::TestCase

  setup do
    scaffold_template
    
    @org = Org.last
    @question = @template.phases.first.sections.first.questions.first
    
    @suggested_answer = SuggestedAnswer.create(org: @org, question: @question, text: 'Test', 
                                               is_example: true)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not SuggestedAnswer.new.valid?
    assert_not SuggestedAnswer.new(org: @org, text: 'Tester').valid?, "expected the 'question' field to be required"
    assert_not SuggestedAnswer.new(question: @question, text: 'Tester').valid?, "expected the 'org' field to be required"
    assert_not SuggestedAnswer.new(org: @org, question: @question).valid?, "expected the 'text' field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = SuggestedAnswer.new(org: @org, question: @question, text: 'Tester')
    assert a.valid?, "expected the 'org', 'question' and 'text' fields to be enough to create an SuggestedAnswer! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s returns the text" do
    assert_equal @suggested_answer.text, @suggested_answer.to_s
  end
  
  # ---------------------------------------------------
  test "can CRUD SuggestedAnswer" do
    obj = SuggestedAnswer.create(org: @org, question: @question, text: 'Tester')
    assert_not obj.id.nil?, "was expecting to be able to create a new SuggestedAnswer: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'my tester'
    obj.save!
    obj.reload
    assert_equal 'my tester', obj.text, "Was expecting to be able to update the text of the SuggestedAnswer!"
  
    assert obj.destroy!, "Was unable to delete the SuggestedAnswer!"
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    suggested_answer = SuggestedAnswer.new(question: @question, text: 'Testing')
    verify_belongs_to_relationship(suggested_answer, @org)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    suggested_answer = SuggestedAnswer.new(org: @org, text: 'Testing')
    verify_belongs_to_relationship(suggested_answer, @question)
  end
end