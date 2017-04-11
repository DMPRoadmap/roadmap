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
    scaffold_plan
    @user = @plan.owner
    
    # This should NOT be unnecessary! Owner should have full access
    role = Role.where(user: @user, plan: @plan).first
    role.access = 15
    role.save!
  end

  # GET /plans (plans_path)
  # ----------------------------------------------------------
  test 'load the list of plans page' do
    # Should redirect user to the root path if they are not logged in!
    get plans_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get plans_path
    assert_response :success
    assert assigns(:plans)
  end
  
  # GET /plans/new (new_plan_path)
  # ----------------------------------------------------------
  test 'load the new plan page' do
    # Should redirect user to the root path if they are not logged in!
    get new_plan_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get new_plan_path
    assert_response :success
    assert assigns(:plan)
    assert assigns(:funders)
  end

  # POST /plans (plans_path)
  # ----------------------------------------------------------
  test "create a new plan" do
    params = {template_id: @template.id}
    # Should redirect user to the root path if they are not logged in!
    post plans_path, params
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post plans_path, params
    assert_equal _('Plan was successfully created.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to "#{plan_url(Plan.last)}?editing=true"
    assert assigns(:plan)
    assert_equal "#{_('My plan')} (#{@template.title})", Plan.last.title, "expected the record to have been created"
    
# TODO: We should also test the various template routes: funder, institution, generic
    
# TODO: Reactivate this once the validations on the model are in place!
    # Invalid object
#    post plans_path, {plan: {title: nil, template: @template}}
#    assert flash[:notice].starts_with?(_('Could not create your'))
#    assert_response :success
#    assert assigns(:plan)
  end 

  # GET /plan/:id (plan_path)
  # ----------------------------------------------------------
  test 'show the plan page' do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(plan_path(@plan))
    
    sign_in @user
    get plan_path(@plan)
    assert_response :success
    assert assigns(:plan)
    assert_not assigns(:editing)
    assert assigns(:selected_guidance_groups)
  end

  # GET /plan/:id/edit (edit_plan_path)
  # ----------------------------------------------------------
  test 'show the edit plan page' do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(edit_plan_path(@plan))
    
    sign_in @user    
    get edit_plan_path(@plan)
    assert_response :success
    assert assigns(:plan)
    assert assigns(:phase)
    assert assigns(:readonly)
  end

  # PUT /plan/:id (plan_path)
  # ----------------------------------------------------------
  test 'update the plan' do
    params = {title: 'Testing UPDATE'}
    # Should redirect user to the root path if they are not logged in!
    put plan_path(@plan), {plan: params}
    assert_unauthorized_redirect_to_root_path
    
    # User who is does not have access to the plan
    sign_in User.first
    put plan_path(@plan), {plan: params}
    assert_equal _('You are not authorized to perform this action.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to plans_url
    
    sign_in @user
    
    put plan_path(@plan), {plan: params}
    assert_equal _('Plan was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to plan_url(@plan)
    assert assigns(:plan)
    assert_equal 'Testing UPDATE', @plan.reload.title, "expected the record to have been updated"
    
# TODO: Reactivate this once the validations on the model are in place!
    # Invalid object
#    put plan_path(@plan), {plan: {title: nil}}
#    assert flash[:notice].starts_with?(_('Could not update your'))
#    assert_response :success
#    assert assigns(:plan)
  end
  
  # DELETE /plan/:id (plan_path)
  # ----------------------------------------------------------
  test "delete the plan" do
    id = @plan.id
    # Should redirect user to the root path if they are not logged in!
    delete plan_path(@plan)
    assert_unauthorized_redirect_to_root_path
    
    # User who is does not have access to the plan
    sign_in User.first
    delete plan_path(@plan)
    assert_equal _('You are not authorized to perform this action.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to plans_url
    
    sign_in @user
    delete plan_path(@plan)
    assert_equal _('Plan was successfully deleted.'), flash[:notice]
    assert_response :redirect
    assert assigns(:plan)
    assert_redirected_to plans_path
    assert_raise ActiveRecord::RecordNotFound do 
      Plan.find(id).nil?
    end
  end
  
  # PUT /plans/:id/update_guidance_choices (update_guidance_choices_plan_path)
  # ----------------------------------------------------------
  test "update the selected guidance" do
    params = {plan_guidance_group_ids: [GuidanceGroup.first.id, GuidanceGroup.last.id]}
    
    put update_guidance_choices_plan_path(@plan, format: :json), {plan: params}
    assert_unauthorized_redirect_to_root_path
    
    # User who is does not have access to the plan
    sign_in User.first
    put update_guidance_choices_plan_path(@plan, format: :json), {plan: params}
    assert_equal _('You are not authorized to perform this action.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to plans_url
    
    sign_in @user
    put update_guidance_choices_plan_path(@plan, format: :json), {plan: params}
    assert_response :success
    
# TODO: The plan_guidance_groups array is always empty so this method isn't actually doing anything yet
#       is it old code that is no longer used or is there a problem with implementation? Should we be 
#       auto-populating it on plan creation?
    #assert @plan.plan_guidance_groups.include?(GuidanceGroup.first), "expected the plan to have the first GuidanceGroup selected"
    #assert @plan.plan_guidance_groups.include?(GuidanceGroup.last), "expected the plan to have the last GuidanceGroup selected"
  end
  
  # GET /plans/:id/share (share_plan_path)
  # ----------------------------------------------------------
  test "get the share plan page" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(share_plan_path(@plan))

    sign_in @user    
    get share_plan_path(@plan)
    assert_response :success
    assert assigns(:plan)
    assert assigns(:plan_data)
  end
  
  # GET /plans/:id/status(format: :json) (status_plan_path)
  # ----------------------------------------------------------
  test "get the plan status" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(status_plan_path(@plan, format: :json))

    sign_in @user    
    get status_plan_path(@plan, format: :json)
    assert_response :success
    assert assigns(:plan)
  end
  
  # GET /plans/:id/answer(format: :json) (answer_plan_path)
  # ----------------------------------------------------------
  test "get the answer to the specified question for the plan" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(answer_plan_path(@plan, format: :json))

    sign_in @user    
    get answer_plan_path(@plan, format: :json)
    assert_response :success
    assert assigns(:plan)
  end
  
  # GET /plans/:id/export (export_plan_path)
  # ----------------------------------------------------------
  test "export the plan" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(export_plan_path(@plan))

    sign_in @user    
    get export_plan_path(@plan)
    assert_response :success
    assert assigns(:plan)
    
    # TODO: We need some better tests here to check the different formats!
  end
  
  # GET /plans/:id/show_export (show_export_plan_path)
  # ----------------------------------------------------------
  test "show the export the plan page" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(show_export_plan_path(@plan))

    sign_in @user    
    get show_export_plan_path(@plan)
    assert_response :success
    assert assigns(:plan)
  end
  
  private
    def try_no_user_and_unauthorized(target)
      # Should redirect user to the root path if they are not logged in!
      get target
      assert_unauthorized_redirect_to_root_path
    
      # User who is does not have access to the plan
      sign_in User.first
      get target
      assert_equal _('You are not authorized to perform this action.'), flash[:notice]
      assert_response :redirect
      assert_redirected_to plans_url
    end
    
end
