require 'test_helper'

class SectionsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    @phase = @template.phases.first
    
    # Get the first Org Admin
    scaffold_org_admin(@template.org)
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. They are defined multiple times though and we need to clean this up! In particular
#       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
#       We should just have:
#
# SHOULD BE:
# --------------------------------------------------
#   sections             GET    /templates/:template_id/phases/:phase_id/sections     sections#index
#                        POST   /templates/:template_id/phases/:phase_id/sections     sections#create
#   section              GET    /templates/:template_id/phases/:phase_id/section/:id  sections#show
#                        PATCH  /templates/:template_id/phases/:phase_id/section/:id  sections#update
#                        PUT    /templates/:template_id/phases/:phase_id/section/:id  sections#update
#                        DELETE /templates/:template_id/phases/:phase_id/section/:id  sections#destroy
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_create_section  POST   /org/admin/templates/sections/:id/admin_create       sections#admin_create
#   admin_update_section  PUT    /org/admin/templates/sections/:id/admin_update       sections#admin_update
#   admin_destroy_section DELETE /org/admin/templates/sections/:id/admin_destroy      sections#admin_destroy
  
  
  
  # POST /org/admin/templates/sections/:id/admin_create (admin_create_section_path)
  # ----------------------------------------------------------
  test "create a new section" do
    params = {phase_id: @phase.id, title: 'Section Tester', number: 99}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_section_path(@phase), {section: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_section_path(@phase), {section: params}
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, edit: 'true', section_id: Section.last.id)
    assert_equal _('Information was successfully created.'), flash[:notice]
    assert_equal 'Section Tester', Section.last.title, "expected the record to have been created!"
    
    # Invalid object
    post admin_create_section_path(@phase), {section: {phase_id: @phase.id, title: nil}}
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, edit: 'true')
    assert assigns(:section)
    assert assigns(:phase)
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
  end 
  
  # PUT /org/admin/templates/sections/:id/admin_update (admin_update_section_path)
  # ----------------------------------------------------------
  test "update the section" do
    params = {title: 'Phase - UPDATE'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_section_path(@phase.sections.first), {section: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put admin_update_section_path(@phase.sections.first), {section: params}
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, section_id: @phase.sections.first.id, edit: 'true')
    assert_equal 'Phase - UPDATE', @phase.sections.first.title, "expected the record to have been updated"
    
    # Invalid save
    put admin_update_section_path(@phase.sections.first), {section: {title: nil}}
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, section_id: @phase.sections.first.id, edit: 'true')
    assert assigns(:section)
    assert assigns(:phase)
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
  end
  
  # DELETE /org/admin/templates/sections/:id/admin_destroy (admin_destroy_section_path)
  # ----------------------------------------------------------
  test "delete the section" do
    id = @phase.sections.first.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_section_path(id: @phase.id, section_id: id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_section_path(id: @phase.id, section_id: id)
    assert_response :redirect
    assert assigns(:section)
    assert assigns(:phase)
    assert_redirected_to admin_show_phase_url(id: @phase.id, edit: 'true' )
    assert_equal _('Information was successfully deleted.'), flash[:notice]
    assert_raise ActiveRecord::RecordNotFound do 
      Section.find(id).nil?
    end
  end
  
end