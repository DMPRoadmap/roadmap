require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_template
    
    @section = @template.phases.first.sections.first
    
    @question = Question.create(text: 'Test question', default_value: 'ABCD', guidance: 'Hello',
                                number: 999, section: @section, 
                                question_format: QuestionFormat.where(option_based: false).first, 
                                option_comment_display: true, modifiable: true)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Question.new.valid?
    assert_not Question.new(section: @section, number: 7).valid?, "expected the 'text' field to be required"
    assert_not Question.new(number: 7, text: 'Testing').valid?, "expected the 'section' field to be required"
    assert_not Question.new(section: @section, text: 'Testing').valid?, "expected the 'number' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Question.new(section: @section, text: 'Testing', number: 7)
    assert a.valid?, "expected the 'text', 'section' and 'number' fields to be enough to create an Question! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s returns the Question text" do
    assert_equal @question.text, @question.to_s
  end
  
  # ---------------------------------------------------
  test "returns the correct themed guidance for the org" do
    all = Theme.first.guidances + Theme.last.guidances
    
    # Attach 2 themes to the question
    @question.themes = [Theme.first, Theme.last]
    @question.save!

    # Attach the first theme's first gudiance's group to the org
    @user.org.guidance_groups << Theme.first.guidances.first.guidance_group
    @user.save!

    assert_not @question.guidance_for_org(@user.org).empty?, "expected guidance to be returned"

    assert @question.guidance_for_org(@user.org).first.first.include?(Theme.first.title), "expected the theme.title"
    assert @question.guidance_for_org(@user.org).first.first.include?(Theme.first.guidances.first.guidance_group.name), "expected the guidance_group.name"
    assert_equal Theme.first.guidances.first, @question.guidance_for_org(@user.org).first.last, "expected the guidance object to be returned"
  end
  
  # ---------------------------------------------------
  test "returns the correct suggested answer for the org" do
    @question.suggested_answers = [SuggestedAnswer.new(org: @user.org, text: 'Test 1', is_example: false),
                                   SuggestedAnswer.new(org: Org.first, text: 'Test 2', is_example: false)]
    @question.save!
    
    assert_equal 'Test 1', @question.get_suggested_answer(@user.org.id).text, "expected the correct suggested answer"
    assert_equal 'Test 2', @question.get_suggested_answer(Org.first.id).text, "expected the correct suggested answer"
    
    org = Org.create(name: 'New One')
    assert_equal nil, @question.get_suggested_answer(org.id), "expected no suggested answer for a new org"
  end
  
  # ---------------------------------------------------
# TODO: amoeba gem doesn't seem to be in play anymore
=begin
  test "should be able to clone a Question (should include its question_options, themes suggested_answers)" do
    Question.all.each do |question|
puts question.inspect
      q = question.amoeba_dup

      assert_equal question.text, q.text, "expected the 'text' field to match"
      assert_equal question.default_value, q.default_value, "expected the 'default_value' field to match"
      assert_equal question.guidance, q.guidance, "expected the 'guidance' field to match"
      assert_equal question.number, q.number, "expected the 'number' field to match"
      assert_equal question.section, q.section, "expected the 'section' field to match"
      assert_equal question.question_format, q.question_format, "expected the 'question_format' field to match"
      assert_equal question.option_comment_display, q.option_comment_display, "expected the 'option_comment_display' field to match"
      assert_equal question.modifiable, q.modifiable, "expected the 'modifiable' field to match"
      
      assert q.question_options.eql?(question.question_options), "expected the clone to carry over all of the question_options instead got: original - #{question.question_options.count}, clone - #{q.question_options.count}"
      assert q.suggested_answers.eql?(question.suggested_answers), "expected the clone to carry over all of the suggested_answers instead got: original - #{question.suggested_answers.count}, clone - #{q.suggested_answers.count}"
      assert q.themes.eql?(question.themes), "expected the clone to carry over all of the suggested_answers instead got: original - #{question.themes.count}, clone - #{q.themes.count}"
    end
  end
=end
  
  # ---------------------------------------------------
  test "can CRUD Question" do
    obj = Question.create(section: @section, text: 'Test ABC', number: 7)
    assert_not obj.id.nil?, "was expecting to be able to create a new Question: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.text, "Was expecting to be able to update the text of the Question!"
  
    assert obj.destroy!, "Was unable to delete the Question!"
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Section" do
    verify_belongs_to_relationship(@question, @template.phases.first.sections.last)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with QuestionFormat" do
    verify_belongs_to_relationship(@question, QuestionFormat.where(option_based: false).last)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Answer" do
    scaffold_plan
    a = Answer.new(user: @user, plan: @plan, text: 'Test Answer')
    verify_has_many_relationship(@question, a, @question.answers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with QuestionOption" do
    qo = QuestionOption.new(text: 'Test', number: 9)
    verify_has_many_relationship(@question, qo, @question.question_options.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with SuggestedAnswer" do
    sa = SuggestedAnswer.new(text: 'Suggested Answer', org: @user.org)
    verify_has_many_relationship(@question, sa, @question.suggested_answers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Themes" do
    t = Theme.new(title: 'Test Theme')
    verify_has_many_relationship(@question, t, @question.themes.count)
  end
end
