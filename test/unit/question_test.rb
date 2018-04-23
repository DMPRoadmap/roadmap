require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  setup do
    # Need to clear the tables until we get seed.rb out of test_helper.rb
    Template.delete_all    
    @funder = init_funder
    @institution = init_institution
    @template = init_template(@institution, published: true)
    @phase = init_phase(@template)
    @section = init_section(@phase)
    @question = init_question(@section)
  end

  test "required fields are required" do
    assert_not Question.new.valid?
    assert_not Question.new(section: @section, number: 7).valid?, "expected the 'text' field to be required"
    assert_not Question.new(number: 7, text: 'Testing').valid?, "expected the 'section' field to be required"
    assert_not Question.new(section: @section, text: 'Testing').valid?, "expected the 'number' field to be required"

    # Ensure the bare minimum and complete versions are valid
    a = Question.new(section: @section, text: 'Testing', number: 7)
    assert a.valid?, "expected the 'text', 'section' and 'number' fields to be enough to create an Question! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  test "to_s returns the Question text" do
    assert_equal @question.text, @question.to_s
  end

  test "option_based? returns the correct boolean value" do
    assert_not @question.option_based?
# TODO: replace with a call to the init_question_format factory method once seeds.rb is no longer being loaded 
    @question.question_format = QuestionFormat.find_by(option_based: true)
    @question.save!
    assert @question.option_based?
  end
  
  test "#deep_copy creates a new question object and attaches new annotations/question_options objects" do
    init_annotation(@institution, @question)
    init_question_option(@question)
    assert_deep_copy(@question, @question.deep_copy, relations: [:annotations, :question_options])
  end
  
# TODO: This method should get moved to a view helper instead
  test "returns the correct themed guidance for the org" do
    theme = init_theme
    guidance_group = init_guidance_group(@institution)
    funder_guidance_group = init_guidance_group(@funder, { title: 'Test funder guidance group' } )
    guidance = init_guidance(guidance_group, { themes: [theme] })
    funder_guidance = init_guidance(funder_guidance_group, { themes: [theme] })

    @question.themes << theme
    @question.save!

    institution_guidances = @question.guidance_for_org(@institution)
    # method retuns a hash {'descriptive string': 'guidances array'}
    assert_equal 1, institution_guidances.length
    assert_equal guidance, institution_guidances.first.last

    funder_guidances = @question.guidance_for_org(@funder)
    # method retuns a hash {'descriptive string', 'guidances array'}
    assert_equal 1, funder_guidances.length
    assert_equal funder_guidance, funder_guidances.first.last
  end
    
  # ---------------------------------------------------
  test "returns the correct annotation for the org" do
    annotation = init_annotation(@institution, @question, { type: Annotation.types[:example_answer] })
    annotation2 = init_annotation(@institution, @question)
    funder_annotation = init_annotation(@funder, @question, { text: 'Test funder example answer', type: Annotation.types[:example_answer] } )
    funder_annotation2 = init_annotation(@funder, @question, { text: 'Test funder guidance'} )
        
    institutional_annotations = @question.get_example_answers(@institution)
    assert_equal 1, institutional_annotations.length
    assert_equal annotation, institutional_annotations.first
    funder_annotations = @question.get_example_answers(@funder)
    assert_equal 1, funder_annotations.length
    assert_equal funder_annotation, funder_annotations.first
  end
end
