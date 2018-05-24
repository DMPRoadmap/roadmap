require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all
    funder = init_funder
    template = init_template(funder, published: true)
    @phase = init_phase(template)
    @section = init_section(@phase)
  end

  test "required fields are required" do
    assert_not Section.new.valid?
    assert_not Section.new(phase: @phase, number: 9).valid?, "expected the 'title' field to be required"
    assert_not Section.new(title: 'Tester', number: 9).valid?, "expected the 'phase' field to be required"
    assert_not Section.new(phase: @phase, title: 'Tester').valid?, "expected the 'number' field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = Section.new(phase: @phase, title: 'Tester', number: 9)
    assert a.valid?, "expected the 'phase', 'title' and 'number' fields to be enough to create an Section! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  test "to_s returns the title" do
    assert_equal @section.title, @section.to_s
  end
  
  test "#deep_copy creates a new section object and attaches new question objects" do
    assert_deep_copy(@section, @section.deep_copy, relations: [:questions])
  end

  test "default values are properly set on section creation" do
    assert(@section.modifiable, 'expected a new section to be modifiable')
  end
end