require 'test_helper'

class AnswerTest < ActiveSupport::TestCase

  setup do
    @user = User.last

    scaffold_plan
    
    q = @plan.template.questions.select{|q| !q.question_format.option_based }.last
    q = Question.create(text: 'Answer Testing', number: 9, 
                        section: @plan.template.phases.first.sections.first,
                        question_format: QuestionFormat.find_by(option_based: false))
    @answer = Answer.create(user: @user, plan: @plan, question: q, text: 'Testing')
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Answer.new.valid?

    # Validate the creation of text based answers
    QuestionFormat.where(option_based: false).each do |qf|
      q = @plan.template.questions.select{|q| q.question_format == qf }.first
      
      assert_not Answer.new(user: @user, question: q, text: 'Testing').valid?, "expected the 'plan' field to be required for a #{qf.title}"
      assert_not Answer.new(plan: @plan, question: q, text: 'Testing').valid?, "expected the 'user' field to be required for a #{qf.title}"
      assert_not Answer.new(user: @user, plan: @plan, text: 'Testing').valid?, "expected the 'question' field to be required for a #{qf.title}"
      assert_not Answer.new(user: @user, question: q, plan: @plan).valid?, "expected the 'text' field to be required  for a #{qf.title}"

      # Ensure the bar minimum and complete versions are valid
      a = Answer.new(user: @user, plan: @plan, question: q, text: 'Testing')
      assert a.valid?, "expected the 'plan', 'user' and 'question' and 'text' fields to be enough to create an Answer for a #{qf.title}! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    end

    # Validate the creation of option based answers (a selection is not required)
    QuestionFormat.where(option_based: true).each do |qf|
      q = @plan.template.questions.select{|q| q.question_format == qf }.first
      
      assert_not Answer.new(user: @user, question: q, question_options: [q.question_options.first]).valid?, "expected the 'plan' field to be required for a #{qf.title}"
      assert_not Answer.new(plan: @plan, question: q, question_options: [q.question_options.first]).valid?, "expected the 'user' field to be required for a #{qf.title}"
      assert_not Answer.new(user: @user, plan: @plan, question_options: [q.question_options.first]).valid?, "expected the 'question' field to be required for a #{qf.title}"
      assert_not Answer.new(user: @user, plan: @plan, question: q).valid?, "expected the 'question_options' field to be required for a #{qf.title}"
      
      # Ensure the bar minimum and complete versions are valid
      a = Answer.new(user: @user, plan: @plan, question: q, question_options: [q.question_options.first])
      assert a.valid?, "expected the 'plan', 'user' and 'question' fields to be enough to create an Answer for a #{qf.title}! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    end
    
  end
  
  # ---------------------------------------------------
  test "cannot have multiple answers to the same question within a plan" do
    q = @plan.template.questions.select{|q| !q.question_format.option_based }.first
    Answer.create(user: @user, plan: @plan, question: @plan.questions.first, text: 'Testing')

    assert_not Answer.new(user: @user, plan: @plan, question: @plan.questions.first, text: 'Another answer to the same question!').valid?, "expected to NOT be able to add an answer to a question that already has an answer!"
  end
  
  # ---------------------------------------------------
  test "can CRUD answers for text based questions" do
    QuestionFormat.where(option_based: false).each do |qf|
      q = @plan.template.questions.select{|q| q.question_format == qf }.first

      assert_not q.nil?, "expected the test template to have a question of type: #{qf.title}"
       
      answr = Answer.create(user: @user, plan: @plan, question: q, text: 'Tested ABC')
      assert_not answr.id.nil?, "was expecting to be able to create a new Answer for a #{qf.title} question: #{answr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      answr.text = 'Testing an update'
      answr.save!
      answr.reload
      assert_equal 'Testing an update', answr.text, "Was expecting to be able to update the text of the Answer for a #{qf.title} question!"
    
      assert answr.destroy!, "Was unable to delete the Answer for a #{qf.title} question!"
    end
  end
    
  # ---------------------------------------------------
  test "can CRUD answers for option based questions" do
    QuestionFormat.where(option_based: true).each do |qf|
      q = @plan.template.questions.select{|q| q.question_format == qf }.first
      
      assert_not q.nil?, "expected the test template to have a question of type: #{qf.title}"
      
      answr = Answer.create(user: @user, plan: @plan, question: q, question_options: [q.question_options.first])
      assert_not answr.id.nil?, "was expecting to be able to create a new Answer for a #{qf.title} question: #{answr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      answr.question_options = [q.question_options.last]
      answr.save!
      answr.reload
      assert answr.question_options.include?(q.question_options.last), "Was expecting the answer to have the '#{q.question_options.last.text}' for a #{qf.title} question!"
      assert_not answr.question_options.include?(q.question_options.first), "Was expecting the answer to no longer have the '#{q.question_options.first.text}' for a #{qf.title} question!"
    
      assert answr.destroy!, "Was unable to delete the Answer for a #{qf.title} question!"
    end
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with User" do
    verify_belongs_to_relationship(@answer, User.last)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Plan" do
    verify_belongs_to_relationship(@answer, Plan.last)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    q = @plan.template.phases.first.sections.first.questions.last
    verify_belongs_to_relationship(@answer, q)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Notes" do
    note = Note.new(text: 'Test Note', user: @user)
    verify_has_many_relationship(@answer, note, @answer.notes.count)
  end
end
