require 'test_helper'

class PhasesControllerTest < ActionDispatch::IntegrationTest
  
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
  end
  
  test "unauthorized user cannot access the show/edit page" do
    get org_admin_template_phase_path(@template, @phase)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get org_admin_template_phase_path(@template, @phase)
    assert_authorized_redirect_to_plans_page
  end

  test 'authorized user can access the show/edit page' do
    sign_in @org_admin
    get org_admin_template_phase_path(@template, @phase)
    assert_response :success
    assert_nil flash[:notice]
    assert_nil flash[:alert]
  end

  test "unauthorized user cannot access the preview phase page" do
    get preview_org_admin_template_phase_path(@template, @phase)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get preview_org_admin_template_phase_path(@template, @phase)
    assert_authorized_redirect_to_plans_page
  end

  test 'authorized user can access the preview phase page' do
    sign_in @org_admin
    get preview_org_admin_template_phase_path(@template, @phase)
    assert_response :success
    assert_nil flash[:notice]
    assert_nil flash[:alert]
  end
  
  test "unauthorized user cannot access the new phase page" do
    get new_org_admin_template_phase_path(@template)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    get new_org_admin_template_phase_path(@template)
    assert_authorized_redirect_to_plans_page
  end

  test 'authorized user can access the new phase page' do
    sign_in @org_admin
    get new_org_admin_template_phase_path(@template)
    assert_response :success
    assert_nil flash[:notice]
    assert_nil flash[:alert]
  end
  
  test 'unauthorized user cannot create a phase' do
    params = { phase: { title: 'New phase', number: 2 } }
    post org_admin_template_phases_path(@template), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    post org_admin_template_phases_path(@template), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can create a phase for an unpublished template' do
    @template.update!(published: false)
    params = { phase: { title: 'New phase', number: 2 } }
    sign_in @org_admin
    post org_admin_template_phases_path(@template), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @template.phases.last.id)
  end
  
  test 'authorized user can create a phase for a published template' do
    params = { phase: { title: 'New phase', number: 2 } }
    sign_in @org_admin
    post org_admin_template_phases_path(@template), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.last.id)
  end
  
  test 'unauthorized user cannot edit a phase' do
    params = { phase: { title: 'New phase' } }
    put org_admin_template_phase_path(@template, @phase), params
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    put org_admin_template_phase_path(@template, @phase), params
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can edit a phase for an unpublished template' do
    @template.update!(published: false)
    params = { phase: { title: 'New phase' } }
    sign_in @org_admin
    put org_admin_template_phase_path(@template, @phase), params
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_phase_path(template_id: @template.id, id: @template.phases.last.id)
  end
  
  test 'authorized user can edit a phase for a published template' do
    params = { phase: { title: 'New phase' } }
    sign_in @org_admin
    put org_admin_template_phase_path(@template, @phase), params
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_phase_path(template_id: template.id, id: template.phases.last.id)
  end
  
  test 'unauthorized user cannot delete a phase' do
    delete org_admin_template_phase_path(@template, @phase)
    assert_unauthorized_redirect_to_root_path
    sign_in @researcher
    delete org_admin_template_phase_path(@template, @phase)
    assert_authorized_redirect_to_plans_page
  end
  
  test 'authorized user can delete a phase from an unpublished template' do
    @template.update!(published: false)
    params = { phase: { title: 'New phase' } }
    sign_in @org_admin
    delete org_admin_template_phase_path(@template, @phase)
    assert_response :redirect
    assert_redirected_to edit_org_admin_template_path(@template.id)
  end
  
  test 'authorized user can delete a phase from a published template' do
    params = { phase: { title: 'New phase' } }
    sign_in @org_admin
    delete org_admin_template_phase_path(@template, @phase)
    assert_response :redirect
    template = Template.latest_version(@template.family_id).first
    assert_redirected_to edit_org_admin_template_path(template.id)
  end
end
