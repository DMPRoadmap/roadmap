require 'test_helper'

class PhaseTest < ActiveSupport::TestCase
  
  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all
    @funder = init_funder
    @template = init_template(@funder, published: true)
    @phase = init_phase(@template)
  end
  
  test "required fields are required" do
    assert_not Phase.new.valid?
    assert_not Phase.new(title: 'Testing', number: 1).valid?, "expected the template field to be required"
    assert_not Phase.new(number: 2, template: @template).valid?, "expected the title field to be required"
    assert_not Phase.new(title: 'Testing', template: @template).valid?, "expected the number field to be required"
    
    # Ensure the bare minimum and complete versions are valid
    a = Phase.new(title: 'Testing', template: @template, number: 2)
    assert a.valid?, "expected the 'title', 'number' and 'template' fields to be enough to create an Phase! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  test "titles scope returns a list of all phase id with their titles for the specified template" do
    init_phase(@template, { title: 'test scope 1', number: 2 })
    init_phase(@template, { title: 'test scope 2', number: 3 })
    titles = Phase.titles(@template)
    assert_equal 3, titles.length, 'expected 3 phases, the orignal and 2 new'
    assert_not titles.select{ |p| p.title == 'test scope 2' }.empty?, "expected to find the second phase"
  end
  
  test "titles scope does not return phases from other templates" do
    init_phase(@template, { title: 'test scope 1', number: 2 })
    template2 = init_template(@funder, { title: 'template 2' })
    init_phase(template2, { title: 'other template scope' })
    titles = Phase.titles(@template)
    assert titles.select{ |p| p.title == 'other template scope' }.empty?, "expected to not find the other template's phase"
  end
  
  test "#deep_copy creates a new phase object and attaches new section objects" do
    assert_deep_copy(@phase, @phase.deep_copy, relations: [:sections])
  end

  test "num_questions returns the total number of questions for the phase" do
    section = init_section(@phase)
    section2 = init_section(@phase, { title: 'Section B', number: 2 })
    init_question(section)
    init_question(section, { text: 'Question number 2', number: 2 })
    init_question(section2)
    assert_equal 3, @phase.num_questions, 'expected 3 questions for the phase, 2 for the 1st section and 1 for the 2nd section'
  end
  
  test "num_questions does not count questions that belong to other templates" do
    section = init_section(@phase)
    init_question(section)
    template2 = init_template(@funder, { title: 'template 2' })
    phase2 = init_phase(template2, { title: 'other template scope' })
    section2 = init_section(phase2)
    init_question(section2)
    assert_equal 1, @phase.num_questions, 'expected 1 question for the phase'
  end
end
