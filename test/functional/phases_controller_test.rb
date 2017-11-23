require 'test_helper'

class PhasesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    
    # Get the first Org Admin
    scaffold_org_admin(@template.org)
    
    @plan = Plan.create!(template: @template, title: 'Test Plan', visibility: :privately_visible,
                         roles: [Role.new(user: @user, creator: true)])
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. They are defined multiple times though and we need to clean this up! In particular
#       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
#       We should just have:
#
# SHOULD BE:
# --------------------------------------------------
#   phases               GET    /templates/:template_id/phases             phases#index
#                        POST   /templates/:template_id/phases             phases#create
#   phase                GET    /templates/:template_id/phase/:id          phases#show
#                        PATCH  /templates/:template_id/phase/:id          phases#update
#                        PUT    /templates/:template_id/phase/:id          phases#update
#                        DELETE /templates/:template_id/phase/:id          phases#destroy
#   edit_phase           GET    /templates/:template_id/phase/:id/edit     phases#edit
#   new_phase            GET    /templates/:template_id/phase/new          phases#new
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_show_phase     GET    /org/admin/templates/phases/:id/admin_show(.:format)    phases#admin_show
#   admin_preview_phase  GET    /org/admin/templates/phases/:id/admin_preview(.:format) phases#admin_preview
#   admin_add_phase      GET    /org/admin/templates/phases/:id/admin_add(.:format)     phases#admin_add
#   admin_update_phase   PUT    /org/admin/templates/phases/:id/admin_update(.:format)  phases#admin_update
#   admin_create_phase   POST   /org/admin/templates/phases/:id/admin_create(.:format)  phases#admin_create
#   admin_destroy_phase  DELETE /org/admin/templates/phases/:id/admin_destroy(.:format) phases#admin_destroy
#
#   edit_plan_phase      GET    /plans/:plan_id/phases/:id/edit(.:format)               phases#edit
#   status_plan_phase    GET    /plans/:plan_id/phases/:id/status(.:format)             phases#status
#   plan_phase           POST   /plans/:plan_id/phases/:id/update(.:format)             phases#update
#   plan_phases          GET    /plans/:plan_id/phases(.:format)                        phases#index
#                        POST   /plans/:plan_id/phases(.:format)                        phases#create
#   new_plan_phase       GET    /plans/:plan_id/phases/new(.:format)                    phases#new
#                        GET    /plans/:plan_id/phases/:id/edit(.:format)               phases#edit
#                        GET    /plans/:plan_id/phases/:id(.:format)                    phases#show
#                        PATCH  /plans/:plan_id/phases/:id(.:format)                    phases#update
#                        PUT    /plans/:plan_id/phases/:id(.:format)                    phases#update
#                        DELETE /plans/:plan_id/phases/:id(.:format)                    phases#destroy
  
  
  
  # GET /plans/:plan_id/phases/:id/edit (edit_plan_phase_path)
  # ----------------------------------------------------------
  test "show the edit phase page" do
    # Should redirect user to the root path if they are not logged in!
    get edit_plan_phase_path(@plan, @template.phases.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    # TODO: Why does the policy check fail when @user is the creator and owner of @plan!?
    #       Trying `@plan.assign_editor(@user)` doesn't work either!
    #get edit_plan_phase_path(@plan, @template.phases.first)
    #assert_response :success
    
    #assert assigns(:plan)
    #assert assigns(:phase)
    #assert assigns(:question_guidance)
  end 
  
  # GET /plans/:plan_id/phases/:id/status (status_plan_phase_path)
  # ----------------------------------------------------------
  test "get the phase's status" do
    # Should redirect user to the root path if they are not logged in!
    get status_plan_phase_path(plan_id: @plan.id, id: @template.phases.first.id), format: :json
    assert_unauthorized_redirect_to_root_path
    
    @plan.assign_creator(@user)
    @plan.save!
    sign_in @user
    
    get status_plan_phase_path(plan_id: @plan.id, id: @template.phases.first.id), format: :json
    assert_response :success
    assert assigns(:plan)
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # GET /org/admin/templates/phases/:id/admin_show (admin_show_phase_path)
  # ----------------------------------------------------------
  test "show the phase" do
    # Should redirect user to the root path if they are not logged in!
    get admin_show_phase_path(@template.phases.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_show_phase_path(@template.phases.first)
    assert_response :success
    
    assert assigns(:phase)
    #assert assigns(:edit)
    assert assigns(:sections)
  end
  
  # GET /org/admin/templates/phases/:id/admin_preview (admin_preview_phase_path)
  # ----------------------------------------------------------
  test "preview the phase" do
    # Should redirect user to the root path if they are not logged in!
    get admin_preview_phase_path(@template.phases.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_preview_phase_path(@template.phases.first)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:phase)
  end
  
  # GET /org/admin/templates/phases/:id/admin_add (admin_add_phase)   Why do we have an id here!?
  # ----------------------------------------------------------
  test "show the new phase page" do
    # Should redirect user to the root path if they are not logged in!
    get admin_add_phase_path(@template.id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_add_phase_path(@template.id)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:phase)
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # POST /org/admin/templates/phases/:id/admin_create (admin_create_phase_path)
  # ----------------------------------------------------------
  test "create a phase " do
    params = {template_id: @template.id, title: 'Phase: Tester 2', number: 2}
    
    @template.dirty = false
    @template.save!
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_phase_path(@template.phases.first), {phase: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_phase_path(@template.phases.first), {phase: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_response :redirect
    assert_redirected_to admin_show_phase_path(id: Phase.last.id)
    assert assigns(:phase)
    assert_equal 'Phase: Tester 2', Phase.last.title, "expected the record to have been created!"
    
    # Make sure that the template's dirty flag got set
    assert @template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid object
    post admin_create_phase_path(@template.phases.first), {phase: {template_id: @template.id}}
    assert flash[:alert].starts_with?(_('Could not create your'))
    assert_response :redirect
    assert assigns(:phase)
    assert assigns(:template)
  end
  
  # PUT /org/admin/templates/phases/:id/admin_update (admin_update_phase_path)
  # ----------------------------------------------------------
  test "update the phase" do
    params = {title: 'Phase - UPDATE'}
    
    @template.dirty = false
    @template.save!
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_phase_path(@template.phases.first), {phase: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    # Valid save
    put admin_update_phase_path(@template.phases.first), {phase: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to admin_show_phase_url(@template.phases.first)
    assert assigns(:phase)
    assert_equal 'Phase - UPDATE', @template.phases.first.title, "expected the record to have been updated"
    
    # Make sure that the template's dirty flag got set
    assert @template.reload.dirty?, "expected the templates dirty flag to be true"
    
    # Invalid save
    put admin_update_phase_path(@template.phases.first), {phase: {title: nil}}
    assert flash[:alert].starts_with?(_('Could not update your'))
    assert_response :redirect
    assert assigns(:phase)
    assert assigns(:template)
    assert assigns(:sections)
    assert assigns(:edit)
  end

  # DELETE /org/admin/templates/phases/:id/admin_destroy (admin_destroy_phase_path)
  # ----------------------------------------------------------
  test "delete the phase" do
    id = @template.phases.first.id
    
    @template.dirty = false
    @template.save!
    
    # Should redirect user to the root path if they are not logged in!
    # TODO: Why are we not just using id: here? shouldn't need to specify the key
    delete admin_destroy_phase_path(id: @template.phases.first.id, phase_id: id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_phase_path(id: @template.phases.first.id, phase_id: id)
    assert_response :redirect
    assert_redirected_to admin_template_template_path(@template)
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_raise ActiveRecord::RecordNotFound do 
      Phase.find(id).nil?
    end
    
    # Make sure that the template's dirty flag got set
    assert @template.reload.dirty?, "expected the templates dirty flag to be true"
  end

end
