require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  # TODO: Cleanup these routes! There are duplicates and ones no longer in use!
  #
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   status_plan                   GET      /plans/:id/status                    plans#status
  #   locked_plan                   GET      /plans/:id/locked                    plans#locked
  #   answer_plan                   GET      /plans/:id/answer                    plans#answer
  #   update_guidance_choices_plan  PUT      /plans/:id/update_guidance_choices   plans#update_guidance_choices
  #   delete_recent_locks_plan      POST     /plans/:id/delete_recent_locks       plans#delete_recent_locks
  #   lock_section_plan             POST     /plans/:id/lock_section              plans#lock_section
  #   unlock_section_plan           POST     /plans/:id/unlock_section            plans#unlock_section
  #   unlock_all_sections_plan      POST     /plans/:id/unlock_all_sections       plans#unlock_all_sections
  #   export_plan                   GET      /plans/:id/export                    plans#export
  #   warning_plan                  GET      /plans/:id/warning                   plans#warning
  #   section_answers_plan          GET      /plans/:id/section_answers           plans#section_answers
  #   share_plan                    GET      /plans/:id/share                     plans#share
  #                                 GET      /plans/:id/export                    plans#export
  #   invite_plan                   POST     /plans/:id/invite                    plans#invite
  #   possible_templates_plans      GET      /plans/possible_templates            plans#possible_templates
  #   possible_guidance_plans       GET      /plans/possible_guidance             plans#possible_guidance
  
  #   plans                         GET      /plans                               plans#index
  #                                 POST     /plans                               plans#create
  #   new_plan                      GET      /plans/new                           plans#new
  #   edit_plan                     GET      /plans/:id/edit                      plans#edit
  #   plan                          GET      /plans/:id                           plans#show
  #                                 PATCH    /plans/:id                           plans#update
  #                                 PUT      /plans/:id                           plans#update
  #                                 DELETE   /plans/:id                           plans#destroy
  
  setup do
    @org = Org.first
    scaffold_org_admin(@org)
  end

  # GET /plans (plans_path)
  # ----------------------------------------------------------
  test 'load the list of plans page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_org_path(@org)
    assert_response :success
    assert assigns(:org)
    assert assigns(:languages)
  end
  

  # GET /plans/new (new_plan_path)
  # ----------------------------------------------------------
  test 'load the new plan page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_org_path(@org)
    assert_response :success
    assert assigns(:org)
    assert assigns(:languages)
  end
  
  # POST /plans (plans_path)
  # ----------------------------------------------------------
  test "create a new plan" do
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
  

  # GET /plan/:id (plan_path)
  # ----------------------------------------------------------
  test 'show the plan page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_show_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_show_org_path(@org)
    assert_response :success
    assert assigns(:org)
  end

  # GET /plan/:id/edit (edit_plan_path)
  # ----------------------------------------------------------
  test 'show the edit plan page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_show_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_show_org_path(@org)
    assert_response :success
    assert assigns(:org)
  end

  
  # PUT /plan/:id (plan_path)
  # ----------------------------------------------------------
  test 'update the plan' do
    params = {name: 'Testing UPDATE'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_org_path(@org), {org: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_org_path(@org), {org: params}
    assert_equal _('Organisation was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_show_org_path(@org)
    assert assigns(:org)
    assert_equal 'Testing UPDATE', @org.reload.name, "expected the record to have been updated"
    
    # Invalid object
    put admin_update_org_path(@org), {org: {name: nil}}
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
    assert_response :success
    assert assigns(:org)
  end
  
  # DELETE /plan/:id (plan_path)
  # ----------------------------------------------------------
  test "delete the plan" do
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
  
  # GET /plans/:id/share (share_plan_path)
  # ----------------------------------------------------------
  test "get the share plan page" do
    
  end
  
  # GET /plans/:id/status (status_plan_path)
  # ----------------------------------------------------------
  test "get the plan status" do
    
  end
  
  # GET /plans/:id/section_answers (section_answers_plan_path)
  # ----------------------------------------------------------
  test "get the section answers" do
    
  end
  
  # GET /plans/:id/answer (answer_plan_path)
  # ----------------------------------------------------------
  test "get the answer to the specified question for the plan" do
    
  end
  
  # GET /plans/:id/export (export_plan_path)
  # ----------------------------------------------------------
  test "export the plan" do
    
  end
end
