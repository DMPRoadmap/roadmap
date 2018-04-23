require 'test_helper'

class TemplateVersioningTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @org = init_funder
    @org_admin = init_org_admin(@org)
    # Create an inital template
    @template = init_template(@org, {
      title: 'Test Template Versioning', 
      visibility: Template.visibilities[:publicly_visible]
    })
    phase = init_phase(@template, { title: 'Initial phase' })
    section = init_section(phase, { title: 'Initial section' })
    question = init_question(section, { text: 'Initial question' })
    init_annotation(@org, question, { text: 'Initial annotation' })
    init_question_option(question, { text: 'Initial question option' })
    @template.update!({ published: true })
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its phases are modified and it is already published' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    put admin_update_phase_path @template.phases.first, {phase: {title: 'UPDATED'}}
#    @template.reload
#    assert_not_equal @initial_version, @template.version, "expected the version to have incremented"
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its sections are modified and it is already published' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    put admin_update_section_path @template.phases.first.sections.first, {section: {title: 'UPDATED'}}
#    @template.reload
#    assert_not_equal @initial_version, @template.version, "expected the version to have incremented"
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its questions are modified and it is already published' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    put admin_update_question_path @template.phases.first.sections.first.questions.first, {question: {text: 'UPDATED'}}
#    @template.reload
#    assert_not_equal @initial_version, @template.version, "expected the version to have incremented"
  end

  # ----------------------------------------------------------
  test 'template does NOT get versioned if its unpublished' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    # Change the title after its been published
#    put org_admin_template_path(@template), {template: {title: "Blah blah blah"}}
#    @template = Template.current(@family_id)

#    assert_equal @initial_version, @template.version, "expected the version to have stayed the same"
#    assert_equal @initial_id, @template.id, "expected the id to been the same"
#    assert_equal @family_id, @template.family_id, "expected the family_id to match"
#    assert_equal false, @template.published?, "expected the version to have remained unpublished"
  end

  # ----------------------------------------------------------
  test 'publishing a plan unpublishes the old published plan' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    get publish_org_admin_template_path(@template)
#    assert_not Template.live(@family_id).nil?
#    assert_equal 1, Template.where(org: @user.org, family_id: @family_id, published: true).count
  end

  # ----------------------------------------------------------
  test 'unpublishing a plan makes all historical versions unpublished' do
# REINSTATE THIS TEST AFTER REFACTORING TEMPLATE VERSIONING
#    get publish_org_admin_template_path(@template)
#    get unpublish_org_admin_template_path(@template)
#    assert Template.live(@family_id).nil?
  end
end
