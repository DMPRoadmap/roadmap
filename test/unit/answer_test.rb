require 'test_helper'

class AnswerTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    # generate a template and plan
    template = generate_complete_template
    
    project = Project.new({
      title: 'Test Project',
      organisation: @user.organisation
    })
    project.dmptemplate = template
    project.save!
    
    @plan = project.plans.first
    
    qs = template.phases.first.versions.first.sections.first.questions
    @text_area_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Text Area' ) }.first
    @text_field_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Text Field' ) }.first
    @radio_button_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Radio Button' ) }.first
    @check_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Check Box' ) }.first
    @select_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Dropdown' ) }.first
    @multi_select_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Multi Select Box' ) }.first
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Answer.new.valid?
    assert_not Answer.new(user: @user, question: @text_area_question).valid?, "expected the 'text' field to be required"
    assert_not Answer.new(plan: @plan, question: @text_area_question, text: 'Testing').valid?, "expected the 'user' field to be required"
    assert_not Answer.new(user: @user, question: @text_area_question, text: 'Testing').valid?, "expected the 'plan' field to be required"
    assert_not Answer.new(user: @user, plan: @plan, text: 'Testing').valid?, "expected the 'question' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Answer.new(user: @user, plan: @plan, question: @text_area_question, text: 'Testing')
    assert a.valid?, "expected the 'text', 'plan', 'user' and 'question' fields to be enough to create an Answer! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "cannot have multiple answers to the same question within a plan" do
    Answer.create(user: @user, plan: @plan, question: @text_area_question, text: 'Tested ABC')

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
