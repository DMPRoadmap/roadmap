require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  setup do
    scaffold_template
    
    @section = Section.create(title: 'Test Section', description: 'My test section', number: 99,
                              published: true, phase: @template.phases.first, modifiable: false)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Section.new.valid?
    assert_not Section.new(phase: @template.phases.last, number: 9).valid?, "expected the 'title' field to be required"
    assert_not Section.new(title: 'Tester', number: 9).valid?, "expected the 'phase' field to be required"
    assert_not Section.new(phase: @template.phases.last, title: 'Tester').valid?, "expected the 'number' field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = Section.new(phase: @template.phases.last, title: 'Tester', number: 9)
    assert a.valid?, "expected the 'phase', 'title' and 'number' fields to be enough to create an Section! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "to_s returns the title" do
    assert_equal @section.title, @section.to_s
  end
  
  # ---------------------------------------------------
  test "deep copy" do
    verify_deep_copy(@section, ['id', 'created_at', 'updated_at'])
  end
  
  # ---------------------------------------------------
  test "can CRUD Section" do
    obj = Section.create(phase: @template.phases.last, title: 'Tester', number: 9)
    assert_not obj.id.nil?, "was expecting to be able to create a new Section: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.description = 'my tester'
    obj.save!
    obj.reload
    assert_equal 'my tester', obj.description, "Was expecting to be able to update the description of the Section!"
  
    assert obj.destroy!, "Was unable to delete the Section!"
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Phase" do
    section = Section.new(title: 'Tester', number: 99)
    verify_belongs_to_relationship(section, @template.phases.first)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Question" do
    question = Question.new(text: 'Testing', number: 1)
    verify_has_many_relationship(@section, question, @section.questions.count)
  end
end