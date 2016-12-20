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
    
    qs = template.phases.first.versions.first.sections.first.questions
    @text_area_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Text Area' ) }.first
    @text_field_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Text Field' ) }.first
    @radio_button_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Radio Button' ) }.first
    @check_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Check Box' ) }.first
    @select_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Dropdown' ) }.first
    @multi_select_box_question = qs.select{ |q| q.question_format == QuestionFormat.find_by(title: 'Multi Select Box' ) }.first
  end

=begin
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Answer.new.valid?
    assert_not Answer.new(user: @user).valid?
    assert_not Answer.new(plan: @plan).valid?
    assert_not Answer.new(question: @text_area_question).valid?
    assert_not Answer.new(user: @user, plan: @plan).valid?
    assert_not Answer.new(user: @user, question: @text_area_question).valid?
    assert_not Answer.new(plan: @plan, question: @text_area_question).valid?
    
    # Ensure the bar minimum and complete versions are valid
    assert Answer.new(user: @user, plan: @plan, question: @text_area_question).valid?
  end
  
  # ---------------------------------------------------
  test "cannot have multiple answers to the same question within a plan" do
    Answer.create(user: @user, plan: @plan, question: @text_area_question, text: 'Tested ABC')
    assert_not Answer.new(user: @user, plan: @plan, question: @text_area_question).valid?
    
puts @plan.answers.inspect
    
    assert_not Answer.new(user: @user, plan: @plan, question: @text_area_question, text: 'ABCD').valid?
  end
  
  # ---------------------------------------------------
  test "can CRUD answers for text based questions" do
    [@text_area_question, @text_field_question].each do |q|
      answr = Answer.new(user: @user, plan: @plan, question: q, text: 'Tested ABC')
      assert_not answr.id.nil?, "was expecting to be able to create a new Answer for a #{q.question_format.title} question: #{answr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      answr.text = 'Testing an update'
      answr.save!
      answr.reload
      assert_equal 'Testing an update', answr.text, "Was expecting to be able to update the text of the Answer for a #{q.question_format.title} question!"
    
      assert answr.destroy!, "Was unable to delete the Answer for a #{q.question_format.title} question!"
    end
  end
=end
    
end
