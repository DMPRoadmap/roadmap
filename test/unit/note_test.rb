require 'test_helper'

class NoteTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_plan
    
    q = @plan.template.questions.select{|q| !q.question_format.option_based }.first
    @answer = Answer.create(user: @user, plan: @plan, question: q, text: 'Testing')
    
    @note = Note.create(answer: @answer, user: @user, text: 'Test Note', archived: true,
                        archived_by: User.last)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Note.new.valid?
    assert_not Note.new(user: @user, answer: @answer).valid?, "expected the 'text' field to be required"
    assert_not Note.new(answer: @answer, text: 'Testing').valid?, "expected the 'user' field to be required"
    assert_not Note.new(user: @user, text: 'Testing').valid?, "expected the 'answer' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Note.new(user: @user, answer: @answer, text: 'Testing')
    assert a.valid?, "expected the 'text', 'answer' and 'user' fields to be enough to create an Note! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "can CRUD Note" do
    obj = Note.create(user: @user, answer: @answer, text: 'Tested ABC')
    assert_not obj.id.nil?, "was expecting to be able to create a new Note: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.text, "Was expecting to be able to update the text of the Note!"
  
    assert obj.destroy!, "Was unable to delete the Note!"
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Answer" do
    verify_belongs_to_relationship(@note, @answer)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with User" do
    verify_belongs_to_relationship(@note, @user)
  end
end
