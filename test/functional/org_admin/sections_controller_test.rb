require 'test_helper'

class SectionsControllerTest < ActionDispatch::IntegrationTest
  
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
  end

  test "unauthorized user cannot access the index page" do
    get org_admin_template_phase_sections_path(@template, @phase)
    assert_unauthorized_redirect_to_root_path
  end

  test 'authorized user can access the index page' do
    [@researcher, @org_admin].each do |user|
      sign_in user
      get org_admin_template_phase_sections_path(@template, @phase)
      assert_response :success, "expected #{user.name(false)} to be able to access the section_controller#index page"
      assert_nil flash[:notice]
      assert_nil flash[:alert]
    end
  end

  test "unauthorized user cannot access the section_controller#show page" do
    get org_admin_template_phase_section_path(@template, @phase, @section)
    assert_unauthorized_redirect_to_root_path
  end

  test 'authorized user can access the section_controller#show page' do
    [@researcher, @org_admin].each do |user|
      sign_in user
      get org_admin_template_phase_section_path(@template, @phase, @section)
      assert_response :success, "expected #{user.name(false)} to be able to access the section_controller#show page"
      assert_nil flash[:notice]
      assert_nil flash[:alert]
    end
  end

  test "unauthorized user cannot access the section_controller#edit page" do
    get edit_org_admin_template_phase_section_path(@template, @phase, @section)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get edit_org_admin_template_phase_section_path(@template, @phase, @section)
    assert_authorized_redirect_to_plans_page
  end

  test 'authorized user can access the section_controller#edit page' do
    sign_in @org_admin
    get edit_org_admin_template_phase_section_path(@template, @phase, @section)
    assert_response :success
    assert_nil flash[:notice]
    assert_nil flash[:alert]
  end

  test 'unauthorized user cannot call section_controller#create' do
    params = { section: { title: 'New section', number: 2 } }
    post org_admin_template_phase_sections_path(@template, @phase), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post org_admin_template_phase_sections_path(@template, @phase), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'unauthorized user cannot call section_controller#create for another org\'s template' do
    params = { section: { title: 'New section', number: 2 } }
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    sign_in @org_admin
    post org_admin_template_phase_sections_path(funder_template, funder_phase), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call section_controller#create for an unpublished template' do
    @template.update!(published: false)
    params = { section: { title: 'New section', number: 2 } }
    sign_in @org_admin
    post org_admin_template_phase_sections_path(@template, @phase), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id, section: @phase.sections.last.id)
  end
  
  test 'authorized user can call section_controller#create for a published template' do
    params = { section: { title: 'New section', number: 2 } }
    sign_in @org_admin
    post org_admin_template_phase_sections_path(@template, @phase), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id, section: template.phases.first.sections.last.id)
  end
  
  test 'unauthorized user cannot call section_controller#edit' do
    params = { section: { title: 'Edited section' } }
    put org_admin_template_phase_section_path(@template, @phase, @section), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    put org_admin_template_phase_section_path(@template, @phase, @section), params
    assert_authorized_redirect_to_plans_page
  end

  test 'unauthorized user cannot call section_controller#edit for another org\'s template' do
    params = { section: { title: 'Edited section' } }
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    funder_section = init_section(funder_phase)
    sign_in @org_admin
    put org_admin_template_phase_section_path(funder_template, funder_phase, funder_section), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call section_controller#edit for an unpublished template' do
    @template.update!(published: false)
    params = { section: { title: 'Edited section' } }
    sign_in @org_admin
    put org_admin_template_phase_section_path(@template, @phase, @section), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id, section: @phase.sections.last.id)
  end
  
  test 'authorized user can call section_controller#edit for a published template' do
    params = { section: { title: 'Edited section' } }
    sign_in @org_admin
    put org_admin_template_phase_section_path(@template, @phase, @section), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id, section: template.phases.first.sections.last.id)
  end
  
  test 'unauthorized user cannot call section_controller#destroy' do
    delete org_admin_template_phase_section_path(@template, @phase, @section)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    delete org_admin_template_phase_section_path(@template, @phase, @section)
    assert_authorized_redirect_to_plans_page
  end
  
  test 'unauthorized user cannot call section_controller#destroy for another org\'s template' do
    funder = init_funder
    funder_template = init_template(funder)
    funder_phase = init_phase(funder_template)
    funder_section = init_section(funder_phase)
    sign_in @org_admin
    delete org_admin_template_phase_section_path(funder_template, funder_phase, funder_section)
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can call section_controller#destroy for an unpublished template' do
    @template.update!(published: false)
    sign_in @org_admin
    delete org_admin_template_phase_section_path(@template, @phase, @section)
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @phase.id)
  end
  
  test 'authorized user can call section_controller#destroy for a published template' do
    sign_in @org_admin
    delete org_admin_template_phase_section_path(@template, @phase, @section)
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.first.id)
  end
end