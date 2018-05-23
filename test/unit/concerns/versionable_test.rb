require 'test_helper'

class VersionableTest < ActiveSupport::TestCase
  include Versionable

  setup do
    @template = create_template
  end
  def create_template
    funder = init_funder
    template = init_template(funder)
    phase = init_phase(template)
    section = init_section(phase)
    question = init_question(section)
    init_annotation(funder, question)
    return template
  end
  test "versionable concern is included" do
    assert(self.respond_to?(:get_modifiable))
  end
  test "#find_in_space raises ArgumentError when search_scape does not respond_to to each" do
    exception = assert_raises(ArgumentError) do
      find_in_space(nil, nil)
    end
    assert_equal(_('The search_space does not respond to each'), exception.message)
  end
  test "#find_in_space raises ArgumentError when search_scape does not have elements" do
    exception = assert_raises(ArgumentError) do
      find_in_space(nil, [])
    end
    assert_equal(_('The search space does not have elements associated'), exception.message)
  end
  test "#find_in_space looks for the object in the search_scape that has elements of its same class" do
    # Looking for phase
    phase = init_phase(@template)
    assert_equal(@template.phases.first, find_in_space(phase, @template.phases), 'phase found in the space')
    phase.number = 2
    assert_not(find_in_space(phase, @template.phases), 'phase not found in the space')
    # Looking for section
    section = init_section(Phase.new)
    assert_equal(@template.phases.first.sections.first,
      find_in_space(section, @template.phases.first.sections),
      'section found in the space')
    section.number = 2
    assert_not(find_in_space(section, @template.phases.first.sections), 'section not found in the space')
    # Looking for a question
    question = init_question(Section.new)
    assert_equal(@template.phases.first.sections.first.questions.first,
      find_in_space(question, @template.phases.first.sections.first.questions),
      ' question found in the space')
    question.number = 2
    assert_not(find_in_space(question, @template.phases.first.sections.first.questions), 'question not found in the space')
    # Looking for an annotation
    annotation = init_annotation(@template.org, Question.new)
    assert_equal(@template.phases.first.sections.first.questions.first.annotations.first,
      find_in_space(annotation, @template.phases.first.sections.first.questions.first.annotations), 'annotation found in the space')
    annotation.text = 'foo'
    assert_not(find_in_space(annotation, @template.phases.first.sections.first.questions.first.annotations))
    # Looking for something else
    assert_not(find_in_space({}, [{}]))
  end
  test "#find_in_space looks for the object in the relation" do
    # Looking for section
    section = init_section(@template.phases.first)
    assert_equal(@template.phases.first.sections.first,
      find_in_space(section, @template.phases), 'section found in the space through its phase number')
    # Looking for question
    question = init_question(@template.phases.first.sections.first)
    assert_equal(@template.phases.first.sections.first.questions.first,
      find_in_space(question, @template.phases), 'question found in the space through its phase/section number')
    # Looking for annotation
    annotation = init_annotation(@template.org, @template.phases.first.sections.first.questions.first)
    assert_equal(@template.phases.first.sections.first.questions.first.annotations.first,
      find_in_space(annotation, @template.phases), 'annotation found int the space through its phase/section/question number')
    # Looking for a question in a not known search_space
    assert_not(find_in_space(Question.new, [{}]))
  end
  test "#find_in_space looks for an object that does not belong to the hierarchy" do
    question = init_question(@template.phases.first.sections.first)
    question.phase.number = 2
    assert_not(find_in_space(question, @template.phases))
  end

  test "#get_new raises ArgumentError unless the object respond_to template" do
    exception = assert_raises(ArgumentError) do
      get_new(@template)
    end
    assert_equal(_('obj should be a Phase, Section, Question, or Annotation'), exception.message)
  end

  test "#get_new raises RuntimeError when template is not latest" do
    @template.published = true
    @template.generate_version!

    hierarchy_objects = [
      Phase.new(template_id: @template.id),
      Section.new(phase_id: @template.phases.first.id),
      Question.new(section_id: @template.phases.first.sections.first.id),
      Annotation.new(question_id: @template.phases.first.sections.first.questions.first.id)
    ]

    hierarchy_objects.each do |obj|
      exception = assert_raises(RuntimeError) do
        get_new(obj)
      end
      assert_equal(_('A historical template cannot be retrieved for being modified'), exception.message)
    end
  end

  test "#get_new returns same object when template is not published" do
    # Looking for phase
    phase = Phase.new(template: @template)
    new_phase = get_new(phase)
    assert_equal(phase.template_id, new_phase.template_id, 'returns the phase without generating a new template hierarchy')
    # Looking for section
    section = Section.new(phase: @template.phases.first)
    new_section = get_new(section)
    assert_equal(section.phase_id, new_section.phase_id, 'returns the section without generating a new template hierarchy')
    # Looking for question
    question = Question.new(section: @template.phases.first.sections.first)
    new_question = get_new(question)
    assert_equal(question.section_id, new_question.section_id, 'returns the question without generating a new template hierarchy')
    # Looking for annotation fails
    annotation = Annotation.new(question: @template.phases.first.sections.first.questions.first)
    new_annotation = get_new(annotation)
    assert_equal(annotation.question_id, new_annotation.question_id, 'returns the same annotation without generating a new template hierarchy')
  end

  test "#get_new returns new phase when template is published" do
    @template.published = true
    @template.save!
    phase = Phase.new(template: @template)
    new_phase = get_new(phase)
    assert_not_equal(phase.template_id, new_phase.template_id)
  end

  test "#get_new returns new section when template is published" do
    @template.published = true
    @template.save!
    section = Section.new(phase: @template.phases.first)
    new_section = get_new(section)
    assert_not_equal(section.phase_id, new_section.phase_id)
  end

  test "#get_new returns new question when template is published" do
    @template.published = true
    @template.save!
    question = Question.new(section: @template.phases.first.sections.first)
    new_question = get_new(question)
    assert_not_equal(question.section_id, new_question.section_id)
  end

  test "#get_new returns new annotation when template is published" do
    @template.published = true
    @template.save!
    annotation = Annotation.new(question: @template.phases.first.sections.first.questions.first)
    new_annotation = get_new(annotation)
    assert_not_equal(annotation.question_id, new_annotation.question_id)
  end

  test "#get_modifiable raises ArgumentError when the object is not template or object responding to template" do
    exception = assert_raises(ArgumentError) do
      get_modifiable({})
    end
    assert_equal(_('obj should be a Template, Phase, Section, Question, or Annotation'), exception.message)
  end

  test "#get_modifiable raises RuntimeError when template is not latest" do
    @template.published = true
    @template.generate_version!

    hierarchy_objects = [
      @template.phases.first,
      @template.phases.first.sections.first,
      @template.phases.first.sections.first.questions.first,
      @template.phases.first.sections.first.questions.first.annotations.first
    ]
    
    hierarchy_objects.each do |obj|
      exception = assert_raises(RuntimeError) do
        get_modifiable(obj)
      end
      assert_equal(_('A historical template cannot be retrieved for being modified'), exception.message)
    end
  end

  test "#get_modifiable returns same object when template is not published" do
    # Looking for phase
    phase = @template.phases.first
    new_phase = get_modifiable(phase)
    assert_equal(phase.id, new_phase.id, 'returns the same phase id')
    assert_equal(phase.template_id, new_phase.template_id, 'returns the phase without generating a new template hierarchy')
    # Looking for section
    section = @template.phases.first.sections.first
    new_section = get_modifiable(section)
    assert_equal(section.id, new_section.id, 'returns the same section id')
    assert_equal(section.phase.template, new_section.phase.template, 'returns the section without generating a new template hierarchy')
    # Looking for a question
    question = @template.phases.first.sections.first.questions.first
    new_question = get_modifiable(question)
    assert_equal(question.id, new_question.id, 'returns the same question id')
    assert_equal(question.section.phase.template, new_question.section.phase.template, 'returns the question without generating a new template hierarchy')
    # Looking for an annotation
    annotation = @template.phases.first.sections.first.questions.first.annotations.first
    new_annotation = get_modifiable(annotation)
    assert_equal(annotation.id, new_annotation.id, 'returns the same annotation id')
    assert_equal(annotation.question.section.phase.template, new_annotation.question.section.phase.template, 'returns the annotation without generating a new template hierarchy')
  end

  test "#get_modifiable returns new phase when template is published" do
    @template.published = true
    @template.save!
    phase = @template.phases.first
    new_phase = get_modifiable(phase)
    assert_not_equal(phase.id, new_phase.id, 'returns different phase id')
    assert_not_equal(phase.template_id, new_phase.template_id, 'returns different template belonging')
  end

  test "#get_modifiable returns new section when template is published" do
    @template.published = true
    @template.save!
    section = @template.phases.first.sections.first
    new_section = get_modifiable(section)
    assert_not_equal(section.id, new_section.id, 'returns different section id')
    assert_not_equal(section.phase.template, new_section.phase.template, 'returns different template belonging')
  end

  test "#get_modifiable returns new question when template is published" do
    @template.published = true
    @template.save!
    question = @template.phases.first.sections.first.questions.first
    new_question = get_modifiable(question)
    assert_not_equal(question.id, new_question.id, 'returns different question id')
    assert_not_equal(question.section.phase.template, new_question.section.phase.template, 'returns different template belonging')
  end

  test "#get_modifiable returns new annotation when template is published" do
    @template.published = true
    @template.save!
    annotation = @template.phases.first.sections.first.questions.first.annotations.first
    new_annotation = get_modifiable(annotation)
    assert_not_equal(annotation.id, new_annotation.id, 'returns different annotation id')
    assert_not_equal(annotation.question.section.phase.template, new_annotation.question.section.phase.template, 'returns different template belonging')
  end
  
  test "#get_modifiable returns new question_option when template is published" do
    @template.published = true
    @template.save!
    question = @template.phases.first.sections.first.questions.first
    question.question_options << init_question_option(question)
    question_option = question.question_options.first
    new_question = get_modifiable(question)
    new_question_option = new_question.question_options.first
    assert_not_equal(question_option.id, new_question_option.id, 'returns different question_option id')
    assert_not_equal(question_option.question.section.phase.template, new_question_option.question.section.phase.template, 'returns different template belonging')
  end
end