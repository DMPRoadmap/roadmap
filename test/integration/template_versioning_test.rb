require 'test_helper'

class TemplateVersioningTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_template
    scaffold_org_admin(@template.org)

    sign_in @user

    # Make sure the template starts out as unpublished. The controller will not allow changes once its published
    @template.published = false
    @template.save!

    @initial_id = @template.id
    @initial_version = @template.version
    @initial_title = @template.title
    @dmptemplate_id = @template.dmptemplate_id
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its phases are modified and it is already published' do
    @template.dirty = false
    @template.save!

    put admin_update_phase_path @template.phases.first, {phase: {title: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its sections are modified and it is already published' do
    @template.dirty = false
    @template.save!

    put admin_update_section_path @template.phases.first.sections.first, {section: {title: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end

  # ----------------------------------------------------------
  test 'template gets versioned when its questions are modified and it is already published' do
    @template.dirty = false
    @template.save!

    put admin_update_question_path @template.phases.first.sections.first.questions.first, {question: {text: 'UPDATED'}}
    @template.reload
    assert @template.dirty
  end

  # ----------------------------------------------------------
  test 'template does NOT get versioned if its unpublished' do
    # Change the title after its been published
    put org_admin_template_path(@template), {template: {title: "Blah blah blah"}}
    @template = Template.current(@dmptemplate_id)

    assert_equal @initial_version, @template.version, "expected the version to have stayed the same"
    assert_equal @initial_id, @template.id, "expected the id to been the same"
    assert_equal @dmptemplate_id, @template.dmptemplate_id, "expected the dmptemplate_id to match"
    assert_equal false, @template.published?, "expected the version to have remained unpublished"
  end

  # ----------------------------------------------------------
  test 'publishing a plan unpublishes the old published plan' do
    get publish_org_admin_template_path(@template)
    assert_not Template.live(@dmptemplate_id).nil?
    assert_equal 1, Template.where(org: @user.org, dmptemplate_id: @dmptemplate_id, published: true).count
  end

  # ----------------------------------------------------------
  test 'unpublishing a plan makes all historical versions unpublished' do
    get publish_org_admin_template_path(@template)
    get unpublish_org_admin_template_path(@template)
    assert Template.live(@dmptemplate_id).nil?
  end
end
