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
    
    @phase.template.dirty = false
    @phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_section_path(@phase), {section: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_section_path(@phase), {section: params}
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, section_id: Section.last.id, r: 'all-templates')
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_equal 'Section Tester', Section.last.title, "expected the record to have been created!"
    
    # Make sure that the template's dirty flag got set
    assert @phase.template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid object
    post admin_create_section_path(@phase), {section: {phase_id: @phase.id, title: nil}}
    assert flash[:alert].starts_with?(_('Could not create your'))
    assert_response :redirect
    assert assigns(:section)
    assert assigns(:phase)
    assert assigns(:edit)
    assert assigns(:open)
    assert assigns(:sections)
  end 
  
  # PUT /org/admin/templates/sections/:id/admin_update (admin_update_section_path)
  # ----------------------------------------------------------
  test "update the section" do
    params = {title: 'Phase - UPDATE'}
    
    @phase.template.dirty = false
    @phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_section_path(@phase.sections.first), {section: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put admin_update_section_path(@phase.sections.first), {section: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(id: @phase.id, section_id: @phase.sections.first.id, r: 'all-templates')
    assert_equal 'Phase - UPDATE', @phase.sections.first.title, "expected the record to have been updated"
    
    # Make sure that the template's dirty flag got set
    assert @phase.template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid save
    put admin_update_section_path(@phase.sections.first), {section: {title: nil}}
    assert flash[:alert].starts_with?(_('Could not update your'))
    assert_response :redirect
    assert assigns(:section)
    assert assigns(:phase)
    assert assigns(:edit)
    assert assigns(:open)
    assert assigns(:sections)
    assert assigns(:section_id)
  end
  
  # DELETE /org/admin/templates/sections/:id/admin_destroy (admin_destroy_section_path)
  # ----------------------------------------------------------
  test "delete the section" do
    id = @phase.sections.first.id
    
    @phase.template.dirty = false
    @phase.template.save!
    
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_section_path(id: @phase.id, section_id: id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_section_path(id: @phase.id, section_id: id)
    assert_response :redirect
    assert assigns(:section)
    assert assigns(:phase)
    assert_redirected_to admin_show_phase_url(id: @phase.id, r: 'all-templates')
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_raise ActiveRecord::RecordNotFound do 
      Section.find(id).nil?
    end
    
    # Make sure that the template's dirty flag got set
    assert @phase.template.reload.dirty?, "expected the templates dirty flag to be true"
  end
  
end