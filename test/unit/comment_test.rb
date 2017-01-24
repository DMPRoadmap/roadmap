require 'test_helper'

class CommentTest < ActiveSupport::TestCase

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
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Comment.new.valid?
    assert_not Comment.new(user: @user, question: @text_area_question).valid?, "expected the 'text' field to be required"
    assert_not Comment.new(plan: @plan, question: @text_area_question, text: 'Testing').valid?, "expected the 'user' field to be required"
    assert_not Comment.new(user: @user, question: @text_area_question, text: 'Testing').valid?, "expected the 'plan' field to be required"
    assert_not Comment.new(user: @user, plan: @plan, text: 'Testing').valid?, "expected the 'question' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Comment.new(user: @user, plan: @plan, question: @text_area_question, text: 'Testing')
    assert a.valid?, "expected the 'text', 'plan', 'user' and 'question' fields to be enough to create an Comment! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "can CRUD Comment" do
    cmnt = Comment.create(user: @user, plan: @plan, question: @text_area_question, text: 'Tested ABC')
    assert_not cmnt.id.nil?, "was expecting to be able to create a new Comment: #{cmnt.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    cmnt.text = 'Testing an update'
    cmnt.save!
    cmnt.reload
    assert_equal 'Testing an update', cmnt.text, "Was expecting to be able to update the text of the Comment!"
  
    assert cmnt.destroy!, "Was unable to delete the Comment!"
  end
    
end
