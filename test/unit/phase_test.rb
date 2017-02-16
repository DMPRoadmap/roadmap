require 'test_helper'

class PhaseTest < ActiveSupport::TestCase
  
  setup do
    @org = Org.first
    @template = Template.first
    @phase = Phase.create(title: 'Test Phase 1', number: 1, template: @template)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Phase.new.valid?
    assert_not Phase.new(title: 'Testing', number: 1).valid?, "expected the dmptemplate field to be required"
    assert_not Phase.new(number: 2, template: @template).valid?, "expected the title field to be required"
    assert_not Phase.new(title: 'Testing', template: @template).valid?, "expected the number field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = Phase.new(title: 'Testing', template: @template, number: 2)
    assert a.valid?, "expected the 'title', 'number' and 'template' fields to be enough to create an Phase! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "a slug is properly generated when creating a record" do
    a = Phase.create(title: 'Testing 123', template: @template, number: 2)
    assert_equal "testing-123", a.slug
  end
  
  # ---------------------------------------------------
  test "to_s returns the title" do
    assert_equal @phase.title, @phase.to_s
  end
  
  # ---------------------------------------------------
  test "has_sections returns false if there are NO published versions with sections" do
    # TODO: build out this test if the has_sections method is actually necessary
  end
  
  # ---------------------------------------------------
  test "deep copy" do
    verify_deep_copy(@phase, ['id', 'created_at', 'updated_at', 'slug'])
  end
  
  # ---------------------------------------------------
  test "can CRUD Phase" do
    obj = Phase.create(title: 'Testing CRUD', template: @template, number: 4)
    assert_not obj.id.nil?, "was expecting to be able to create a new Phase! - #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.title = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.title, "Was expecting to be able to update the title of the Phase!"
  
    assert obj.destroy!, "Was unable to delete the Phase!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Sections" do
    s = Section.new(title: 'Test Section', number: 2)
    verify_has_many_relationship(@phase, s, @phase.sections.count)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Template" do
    phase = Phase.new(title: 'Tester', number: 9)
    verify_belongs_to_relationship(phase, @template)
  end
end
