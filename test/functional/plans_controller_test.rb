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
    assert assigns(:orgs)
    assert assigns(:funders)
    assert assigns(:default_org)
  end

  # POST /plans (plans_path)
  # ----------------------------------------------------------
  test "create a new plan" do
    params = {plan: {org_id: @template.org.id, template_id: @template.id, title: 'Testing Create'}}
    # Should redirect user to the root path if they are not logged in!
    post plans_path(format: :js), params
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    post plans_path(format: :js), params
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_response :success
    assert assigns(:plan)
    assert_equal "Testing Create", Plan.last.title, "expected the record to have been created"
  
    # assert that the default visibility is used when none is specified
    assert_equal Rails.application.config.default_plan_visibility, Plan.last.visibility, "Expected the plan to have been assigned the default visibility"
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
    assert_equal _('You are not authorized to perform this action.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to plans_url

    sign_in @user

    put plan_path(@plan), {plan: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
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

  # POST/plan/:id
  # ----------------------------------------------------------
  test 'duplicate a plan' do
    # Should redirect user to the root path if they are not logged in!
    post duplicate_plan_path(@plan, format: :js)
    assert_unauthorized_redirect_to_root_path

    # User who is does not have access to the plan
    sign_in User.first
    put plan_path(@plan, format: :js)
    assert_equal _('You are not authorized to perform this action.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to plans_url

    sign_in @user
    post duplicate_plan_path(@plan, format: :js)
    @duplicate_plan = Plan.last
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('copied')
    assert_response :success
    assert assigns(:plan)
    assert_equal 'Copy of Test Plan', @duplicate_plan.title, "Copy of"
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
    assert_equal _('You are not authorized to perform this action.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to plans_url

    sign_in @user
    delete plan_path(@plan)
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
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
    ids = [GuidanceGroup.first.id, GuidanceGroup.last.id]

    # Make sure the guidance is attached to the template first so that its a valid selection!
    q = @template.phases.first.sections.first.questions.first
    q.themes << GuidanceGroup.first.guidances.first.themes.first
    q.themes << GuidanceGroup.last.guidances.first.themes.first
    q.save

    put plan_path(@plan), {plan: {}, guidance_group_ids: ids}
    assert_unauthorized_redirect_to_root_path

    # User who does not have access to the plan
    sign_in User.first
    put plan_path(@plan), {plan: {}, guidance_group_ids: ids}
    assert_equal _('You are not authorized to perform this action.'), flash[:alert]
    assert_response :redirect
    assert_redirected_to plans_url

    sign_in @user
    put plan_path(@plan), {plan: {id: @plan.id}, guidance_group_ids: ids}
    assert_response :redirect
    assert_redirected_to plan_path(@plan)

    @plan.reload
    ggs = @plan.guidance_groups.ids

    assert ggs.include?(GuidanceGroup.first.id), "expected the plan to have the first GuidanceGroup selected"
    assert ggs.include?(GuidanceGroup.last.id), "expected the plan to have the last GuidanceGroup selected"
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
    export_params = {"utf8"=>"✓",
       "phase_id"=>"5470",
       "export"=>{"project_details"=>"true",
       "question_headings"=>"true",
       "unanswered_questions"=>"true",
       "formatting"=>{"font_face"=>"Arial,
       Helvetica,
       Sans-Serif",
       "font_size"=>"12",
       "margin"=>{"top"=>"20",
       "bottom"=>"20",
       "left"=>"20",
       "right"=>"20"}}},
       "format"=>"docx",
       "commit"=>"Download Plan",
       "id"=>"18009"}
    sign_in @user
    get export_plan_path(@plan), export_params
    assert_response :success
    assert assigns(:plan)

    # TODO: We need some better tests here to check the different formats!
  end

  # GET /plans/:id/download (download_plan_path)
  # ----------------------------------------------------------
  test "show the download plan page" do
    # Should redirect user to the root path if they are not logged in!
    try_no_user_and_unauthorized(download_plan_path(@plan))

    sign_in @user
    get download_plan_path(@plan)
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
      assert_equal _('You are not authorized to perform this action.'), flash[:alert]
      assert_response :redirect
      assert_redirected_to plans_url
    end

end
