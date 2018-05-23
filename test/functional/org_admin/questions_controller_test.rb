require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @institution = init_institution
    @researcher = init_researcher(@institution)
    @org_admin = init_org_admin(@institution)
    @template = init_template(@institution, {
      title: 'Test Template', 
      published: true, 
      visibility: Template.visibilities[:publicly_visible]
    })
    @phase = init_phase(@template)
    @section = init_section(@phase)
    @text_area = init_question_format({ title: 'Test question format' })
    @question = init_question(@section)
  end
  
  test 'unauthorized user cannot call question_controller#create' do
    params = { question: { text: 'New question test', number: 2, question_format_id: @text_area.id } }
    post org_admin_template_phase_section_questions_path(@template, @phase, @section), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post org_admin_template_phase_section_questions_path(@template, @phase, @section), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'unauthorized user cannot call question_controller#create for another org\'s template' do
    params = { question: { text: 'New question test', number: 2, question_format_id: @text_area.id } }
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    funder_section = init_section(funder_phase)
    sign_in @org_admin
    post org_admin_template_phase_section_questions_path(funder_template, funder_phase, funder_section), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call question_controller#create for an unpublished template' do
    @template.update!(published: false)
    params = { question: { text: 'New question test', number: 2, question_format_id: @text_area.id } }
    sign_in @org_admin
    post org_admin_template_phase_section_questions_path(@template, @phase, @section), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id, section: @section.id)
  end
  
  test 'authorized user can call question_controller#create for a published template' do
    params = { question: { text: 'New question test', number: 2, question_format_id: @text_area.id } }
    sign_in @org_admin
    post org_admin_template_phase_section_questions_path(@template, @phase, @section), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id, section: template.phases.first.sections.first.id)
  end
  
  test 'unauthorized user cannot call question_controller#edit' do
    params = { section: { text: 'Edited question' } }
    put org_admin_template_phase_section_question_path(@template, @phase, @section, @question), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    put org_admin_template_phase_section_question_path(@template, @phase, @section, @question), params
    assert_authorized_redirect_to_plans_page
  end

  test 'unauthorized user cannot call question_controller#edit for another org\'s template' do
    params = { section: { text: 'Edited question' } }
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    funder_section = init_section(funder_phase)
    funder_question = init_question(funder_section)
    sign_in @org_admin
    put org_admin_template_phase_section_question_path(funder_template, funder_phase, funder_section, funder_question), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call question_controller#edit for an unpublished template' do
    @template.update!(published: false)
    params = { section: { text: 'Edited question' } }
    sign_in @org_admin
    put org_admin_template_phase_section_question_path(@template, @phase, @section, @question), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id, section: @section.id)
  end
  
  test 'authorized user can call question_controller#edit for a published template' do
    params = { section: { text: 'Edited question' } }
    sign_in @org_admin
    put org_admin_template_phase_section_question_path(@template, @phase, @section, @question), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id, section: template.phases.first.sections.first.id)
  end

  test 'unauthorized user cannot call question_controller#destroy' do
    delete org_admin_template_phase_section_question_path(@template, @phase, @section, @question)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    delete org_admin_template_phase_section_question_path(@template, @phase, @section, @question)
    assert_authorized_redirect_to_plans_page
  end
  
  test 'unauthorized user cannot call question_controller#destroy for another org\'s template' do
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    funder_section = init_section(funder_phase)
    funder_question = init_question(funder_section)
    sign_in @org_admin
    delete org_admin_template_phase_section_question_path(funder_template, funder_phase, funder_section, funder_question)
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call question_controller#destroy for an unpublished template' do
    @template.update!(published: false)
    sign_in @org_admin
    delete org_admin_template_phase_section_question_path(@template, @phase, @section, @question)
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id, section: @section.id)
  end
  
  test 'authorized user can call question_controller#destroy for a published template' do
    sign_in @org_admin
    delete org_admin_template_phase_section_question_path(@template, @phase, @section, @question)
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id, section: template.phases.first.sections.first.id)
  end
end