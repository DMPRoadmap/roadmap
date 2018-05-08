require 'test_helper'

class AnnotationsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @org = init_organisation
    @researcher = init_researcher(@org)
    @org_admin = init_org_admin(@org)
    @template = init_template(@org)
    @phase = init_phase(@template)
    @section = init_section(@phase)
    @question = init_question(@section)
  end

  test '#create returns to root_path when user is not signed in to create an annotation' do
    post org_admin_annotations_path(params: {
      annotation: {
        question_id: 1,
        text: 'foo',
        type: :guidance
      }
    })
    assert_redirected_to(root_path)
    assert_equal(_('You need to sign in or sign up before continuing.'), flash[:alert])
  end

  test '#create redirects to org_admin_templates_path when a parameter is missing' do
    sign_in @org_admin

    param_cases = [
      {},
      { annotation: {} },
      { annotation: { question_id: 1 }},
      { annotation: { question_id: 1, text: 'foo' }},
      { annotation: { question_id: 1, type: :example_answer }}
    ]
    param_cases.each do |params|
      post org_admin_annotations_path(params: params)
      assert_redirected_to(org_admin_templates_path)
      assert_equal(_('Missing parameter(s) while attempting to create the annotation'), flash[:alert])
    end
  end

  test '#create redirects to plans_path when user is not allowed to create an annotation' do
    sign_in @researcher
    post org_admin_annotations_path(params: {
      annotation: {
        question_id: @question.id,
        text: 'foo',
        type: :example_answer
      }})
    assert_redirected_to(plans_path)
    assert_equal(_('You are not authorized to perform this action.'), flash[:alert])
  end

  test '#create returns flash message when a new version of the template cannot be created' do
    @template.published = true
    @template.save!
    @template.generate_version!
    sign_in @org_admin
    post org_admin_annotations_path(params: {
      annotation: {
        question_id: @question.id,
        text: 'foo',
        type: :example_answer
      }})
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: @template.id,
          id: @phase.id)}?section_id=#{@section.id}")
    assert_equal(_('Unable to create a new version of this template.'), flash[:alert])
  end

  test '#create creates an annotation' do
    sign_in @org_admin
    post org_admin_annotations_path(params: {
      annotation: {
        question_id: @question.id,
        text: 'foo',
        type: :example_answer
      }})
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: @template.id,
          id: @phase.id)}?section_id=#{@section.id}")
    assert_not(flash[:alert])
    assert_equal(_('Successfully created your annotation.'), flash[:notice])
  end

  test '#update redirects to root_path when user is not signed in to update the annotation' do
    annotation = init_annotation(@org, @question)
    put org_admin_annotation_path(id: annotation.id)
    assert_redirected_to(root_path)
    assert_equal(_('You need to sign in or sign up before continuing.'), flash[:alert])
  end

  test '#update redirects to plans_path when user is not allowed to update the annotation' do
    sign_in @researcher
    annotation = init_annotation(@org, @question)
    put org_admin_annotation_path(id: annotation.id)
    assert_redirected_to(plans_path)
    assert_equal(_('You are not authorized to perform this action.'), flash[:alert])
  end

  test '#update returns flash message when a new version of the template cannot be created' do
    sign_in @org_admin
    annotation = init_annotation(@org, @question)
    @template.published = true
    @template.save!
    @template.generate_version!
    put org_admin_annotation_path(id: annotation.id)
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    assert_equal(_('Unable to create a new version of this template.'), flash[:alert])
  end

  test '#update returns flash message with parameters missing when the annotation passed has missing field' do
    sign_in @org_admin
    annotation = init_annotation(@org, @question)
    put org_admin_annotation_path(id: annotation.id, params: { annotation: { text: 'foo' }})
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    assert_equal(_('Missing parameter(s) while attempting to create the annotation'), flash[:alert])
  end

  test '#update updates the annotation passed' do
    sign_in @org_admin
    annotation = init_annotation(@org, @question)
    put org_admin_annotation_path(id: annotation.id, params: { annotation: annotation.as_json.merge({ text: 'foo' })})
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    assert_not(flash[:alert])
    annotation.reload
    assert_equal('foo', annotation.text)
    assert_equal(_('Successfully updated your annotation.'), flash[:notice])
  end

  test '#destroy returns to root_path when user is not signed in to destroy the annotation' do
    annotation = init_annotation(@org, @question)
    delete org_admin_annotation_path(id: annotation.id)
    assert_redirected_to(root_path)
    assert_equal(_('You need to sign in or sign up before continuing.'), flash[:alert])
  end

  test '#destroy redirects to plans_path when user is not allowed to destroy the annotation' do
    sign_in @researcher
    annotation = init_annotation(@org, @question)
    delete org_admin_annotation_path(id: annotation.id)
    assert_redirected_to(plans_path)
    assert_equal(_('You are not authorized to perform this action.'), flash[:alert])
  end

  test '#destroy returns flash message when a new version of the template cannot be created' do
    annotation = init_annotation(@org, @question)
    sign_in @org_admin
    @template.published = true
    @template.save!
    @template.generate_version!
    delete org_admin_annotation_path(id: annotation.id)
    assert_redirected_to("#{edit_org_admin_template_phase_path(
          template_id: annotation.template.id,
          id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    assert_equal(_('Unable to create a new version of this template.'), flash[:alert])
  end

  test '#destroy removes annotation from the template' do
    annotation = init_annotation(@org, @question)
    sign_in @org_admin
    delete org_admin_annotation_path(id: annotation.id)
    assert_response(:redirect)
    assert_redirected_to("#{edit_org_admin_template_phase_path(
           template_id: annotation.template.id,
           id: annotation.question.section.phase_id)}?section_id=#{annotation.question.section_id}")
    assert_not(flash[:alert])
    assert_equal(_('Successfully removed your annotation.'), flash[:notice])
  end
end