require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  setup do
    @user = User.last

    scaffold_template

    @section = @template.phases.first.sections.first

    @question = Question.create(text: 'Test question', default_value: 'ABCD',
                                number: 999, section: @section,
                                question_format: QuestionFormat.where(option_based: false).first,
                                option_comment_display: true, modifiable: true,
                                themes: [Theme.first],
                                annotations: [Annotation.new(org: @user.org,
                                                text: "just a suggestion")])
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
  test "returns the correct annotation for the org" do
    @question.annotations = [Annotation.create(org: @user.org, text: 'Test 1', type: Annotation.types[:example_answer]),
                            Annotation.create(org: Org.first, text: 'Test 2', type: Annotation.types[:example_answer])]
    @question.save!

    assert_equal 'Test 1', @question.annotations.where(org_id: @user.org.id).first.text, "expected the correct annotation"
    assert_equal 'Test 2', @question.annotations.where(org_id: Org.first.id).first.text, "expected the correct annotation"

    org = Org.create(name: 'New One', links: {"org":[]})
    assert_equal 0, @question.get_example_answers(org.id).length, "expected no annotation for a new org"
  end

  # ---------------------------------------------------
  test "deep copy" do
    verify_deep_copy(@question, ['id', 'created_at', 'updated_at'])
  end

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
  test "can manage has_many relationship with Annotation" do
    sa = Annotation.new(text: 'Suggested Answer', org: @user.org)
    verify_has_many_relationship(@question, sa, @question.annotations.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Themes" do
    t = Theme.new(title: 'Test Theme')
    verify_has_many_relationship(@question, t, @question.themes.count)
  end
end
