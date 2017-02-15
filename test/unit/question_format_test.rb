require 'test_helper'

class QuestionFormatTest < ActiveSupport::TestCase
  
  def setup
    @question = Question.first
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not QuestionFormat.new.valid?
    assert_not QuestionFormat.new(description: 'Random Number').valid?
    
    assert QuestionFormat.new(title: 'Random').valid?
    assert QuestionFormat.new(title: 'Random', description: 'Random Number').valid?
  end
  
  # ---------------------------------------------------
  test "abbreviation must be unique" do
    assert_not QuestionFormat.new(title: QuestionFormat.first.title).valid?
  end
  
  # ---------------------------------------------------
  test "to_s should return the title" do
    assert_equal QuestionFormat.first.title, QuestionFormat.first.to_s
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    qf = QuestionFormat.create(title: 'Random', description: 'Random Number')
    assert_not qf.id.nil?, "was expecting to be able to create a new QuestionFormat : #{qf.errors.collect{ |e| e }.join(', ')}"

    qf.description = 'Random String'
    qf.save!
    assert_equal 'Random String', qf.reload.description, "was expecting the description to have been updated!"

    assert qf.destroy!, "Was unable to delete the QuestionFormat!"
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Questions" do
    qf = QuestionFormat.new(title: 'Random', description: 'Random Number')
    verify_has_many_relationship(qf, @question, qf.questions.count)
  end

end