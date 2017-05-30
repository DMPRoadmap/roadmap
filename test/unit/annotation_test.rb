require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase

  setup do
    scaffold_template

    @org = Org.last
    @question = @template.phases.first.sections.first.questions.first

    @annotation = Annotation.create(org: @org, question: @question, text: 'Test',
                                               type: Annotation.types[:example_answer])
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Annotation.new.valid?
    assert_not Annotation.new(org: @org, text: 'Tester').valid?, "expected the 'question' field to be required"
    assert_not Annotation.new(question: @question, text: 'Tester').valid?, "expected the 'org' field to be required"

    # TODO: introduce validation on the model that requires text to be provided.
    #assert_not Annotation.new(org: @org, question: @question).valid?, "expected the 'text' field to be required"

    # Ensure the bare minimum and complete versions are valid
    a = Annotation.new(org: @org, question: @question, text: 'Tester')
    assert a.valid?, "expected the 'org', 'question' and 'text' fields to be enough to create an Annotation! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "to_s returns the text" do
    assert_equal @annotation.text, @annotation.to_s
  end

  # ---------------------------------------------------
  test "deep_copy" do
    verify_deep_copy(@annotation, ['id', 'created_at', 'updated_at'])
  end

  # ---------------------------------------------------
  test "can CRUD Annotation" do
    obj = Annotation.create(org: @org, question: @question, text: 'Tester')
    assert_not obj.id.nil?, "was expecting to be able to create a new Annotation: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.text = 'my tester'
    obj.save!
    obj.reload
    assert_equal 'my tester', obj.text, "Was expecting to be able to update the text of the Annotation!"

    assert obj.destroy!, "Was unable to delete the Annotation!"
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    annotation = Annotation.new(question: @question, text: 'Testing')
    verify_belongs_to_relationship(annotation, @org)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    annotation = Annotation.new(org: @org, text: 'Testing')
    verify_belongs_to_relationship(annotation, @question)
  end
end