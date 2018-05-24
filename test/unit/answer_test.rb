require 'test_helper'

class AnswerTest < ActiveSupport::TestCase

  setup do
    @user = User.last

    scaffold_plan
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
      assert_not_nil answr.id, "was expecting to be able to create a new Answer for a #{qf.title} question: #{answr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      answr.question_options = [q.question_options.last]
      answr.save!
      answr.reload
      assert answr.question_options.include?(q.question_options.last), "Was expecting the answer to have the '#{q.question_options.last.text}' for a #{qf.title} question!"
      assert_not answr.question_options.include?(q.question_options.first), "Was expecting the answer to no longer have the '#{q.question_options.first.text}' for a #{qf.title} question!"
    
      assert answr.destroy!, "Was unable to delete the Answer for a #{qf.title} question!"
    end
  end
  
  # ---------------------------------------------------
  test "can copy an Answer" do
    qf = QuestionFormat.where(option_based: true).first
    q = @plan.template.questions.select{|q| q.question_format == qf }.first
    
    assert_not_nil q, "expected the test template to have a question of type: #{qf.title}"
    answr = Answer.create(user: @user, plan: @plan, question: q, question_options: [q.question_options.first])
    
    copy = Answer.deep_copy(answr)
    unless answr.text.nil? || copy.text.nil?
      assert_equal answr.text, copy.text, "expected the answer text to be the same"
      assert_equal answr.question.id, copy.question.id, "expected the question to be the same"
      answr.question_options.each do |opt|
        assert copy.question_options.include?(opt), "expected the copy to have question options"
      end
    end
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with User" do
    answer = Answer.create(user: @user, plan: @plan, question:  @plan.template.questions.first, text: 'Testing')
    verify_belongs_to_relationship(answer, User.last)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Plan" do
    answer = Answer.create(user: @user, plan: @plan, question: @plan.template.questions.first, text: 'Testing')
    verify_belongs_to_relationship(answer, @plan)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    answer = Answer.create(user: @user, plan: @plan, question: @plan.template.questions.first, text: 'Testing')
    q = @plan.template.phases.first.sections.first.questions.last
    verify_belongs_to_relationship(answer, q)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Notes" do
    answer = Answer.create(user: @user, plan: @plan, question: @plan.template.questions.first, text: 'Testing')
    note = Note.new(text: 'Test Note', user: @user)
    verify_has_many_relationship(answer, note, answer.notes.count)
  end

  test 'is_valid? returns false when no question is associated to an answer' do
    answer = Answer.new(user: @user, plan: @plan)
    refute(answer.is_valid?)
  end

  test 'is_valid? returns false when an option based answer is empty' do
    q = @plan.template.questions[@plan.template.questions.find_index{ |q| q.question_format.option_based? }]
    answer = Answer.new(user: @user, plan: @plan, question: q)
    refute(answer.is_valid?)
  end

  test 'is_valid? returns false when a non-option based answer is empty' do
    q = @plan.template.questions[@plan.template.questions.find_index{ |q| !q.question_format.option_based? }]
    answer = Answer.new(user: @user, plan: @plan, question: q)
    refute(answer.is_valid?)
  end

  test 'is_valid? returns true when an option based answer is not empty' do
    q = @plan.template.questions[@plan.template.questions.find_index{ |q| q.question_format.option_based? }]
    answer = Answer.new(user: @user, plan: @plan, question: q)
    answer.question_options << q.question_options.first
    assert(answer.is_valid?)
  end

  test 'is_valid? returns true when a non-option based answer is not empty' do
     q = @plan.template.questions[@plan.template.questions.find_index{ |q| !q.question_format.option_based? }]
    answer = Answer.new(user: @user, plan: @plan, question: q, text: 'foo')
    assert(answer.is_valid?)
  end

  test 'after_save callback only sets plan complete to true if the number of answers matches the number of questions' do
    last_question = @plan.template.questions.last
    @plan.template.questions.each do |q|
      a = Answer.new(user: @user, plan: @plan, question: q, text: 'foo')
      if q.question_format.option_based?
        a.question_options << q.question_options.first
      end
      a.save
      if q == last_question
        assert(a.plan.complete)
      else
        refute(a.plan.complete)
      end 
    end
  end

  test 'after_save callback always updates plan.updated_at' do
    plan_before = nil, plan_after = nil
    @plan.template.questions.each do |q|
      a = Answer.new(user: @user, plan: @plan, question: q, text: 'foo')
      updated_at = a.plan.updated_at
      a.save
      new_updated_at = a.plan.updated_at
      assert(updated_at < new_updated_at)
    end
  end
end
