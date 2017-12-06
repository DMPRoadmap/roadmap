require 'test_helper'

class GuidanceGroupsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers

  # TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
  #       these defined. They are defined multiple times though and we need to clean this up! In particular
  #       look at the unnamed routes after 'new_plan_phase' below. They are not named because they are duplicates.
  #       We should just have:
  #
  # SHOULD BE:
  # --------------------------------------------------
  #   guidance_groups      GET    /guidance_groups        guidance_groups#index
  #                        POST   /guidance_groups        guidance_groups#create
  #   guidance_group       GET    /guidance_group/:id     guidance_groups#show
  #                        PATCH  /guidance_groups/:id    guidance_groups#update
  #                        PUT    /guidance_groups/:id    guidance_groups#update
  #                        DELETE /guidance_groups/:id    guidance_groups#destroy
  #
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   admin_show_guidance_group     GET      /org/admin/guidancegroup/:id/admin_show    guidance_groups#admin_show
  #   admin_new_guidance_group      GET      /org/admin/guidancegroup/:id/admin_new     guidance_groups#admin_new
  #   admin_edit_guidance_group     GET      /org/admin/guidancegroup/:id/admin_edit    guidance_groups#admin_edit
  #   admin_destroy_guidance_group  DELETE   /org/admin/guidancegroup/:id/admin_destroy guidance_groups#admin_destroy
  #   admin_create_guidance_group   POST     /org/admin/guidancegroup/:id/admin_create  guidance_groups#admin_create
  #   admin_update_guidance_group   PUT      /org/admin/guidancegroup/:id/admin_update  guidance_groups#admin_update

  setup do
    scaffold_org_admin(GuidanceGroup.first.org)
  end
  
  # GET /org/admin/guidancegroup/:id/admin_new (admin_new_guidance_group_path)
  # ----------------------------------------------------------
  test 'load the new guidance_group page' do
    # Should redirect user to the root path if they are not logged in!
    # TODO: Why is there an id here!? its a new guidance_group!
    get admin_new_guidance_group_path(@user.org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_new_guidance_group_path(@user.org)
    assert_response :success
  end
  
  # POST /org/admin/guidancegroup/:id/admin_create (admin_create_guidance_group_path)
  # ----------------------------------------------------------
  test 'create a new guidance_group' do
    params = {org_id: @user.org.id, published: false, name: 'Testing create'}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_guidance_group_path(@user.org), {guidance_group: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_guidance_group_path(@user.org), {guidance_group: params}
    assert_response :redirect
    assert_redirected_to admin_index_guidance_path(@user.org)
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert assigns(:guidance_group)
    assert_equal 'Testing create', GuidanceGroup.last.name, "expected the record to have been created!"
    
    # Invalid object
    post admin_create_guidance_group_path(@user.org), {guidance_group: {name: nil}}
    assert flash[:alert].start_with?(_('Could not create your'))
    assert_response :success
    assert assigns(:guidance_group)
  end
  
  # GET /org/admin/guidancegroup/:id/admin_edit (admin_edit_guidance_group_path)
  # ----------------------------------------------------------
  test 'load the edit guidance_group page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_guidance_group_path(GuidanceGroup.find_by(org: @user.org))
    assert_response :success
  end
  
  # PUT /org/admin/templates/:id/admin_template (admin_update_guidance_group_path)
  # ----------------------------------------------------------
  test 'update the guidance_group' do
    params = {name: 'Testing UPDATE'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_guidance_group_path(GuidanceGroup.first), {guidance_group: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_guidance_group_path(GuidanceGroup.first), {guidance_group: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :redirect
    assert_redirected_to "#{admin_index_guidance_path(@user.org)}?name=Testing+UPDATE"
    assert assigns(:guidance_group)
    assert_equal 'Testing UPDATE', GuidanceGroup.first.name, "expected the record to have been updated"
    
    # Invalid object
    put admin_update_guidance_group_path(GuidanceGroup.first), {guidance_group: {name: nil}}
    assert flash[:alert].starts_with?(_('Could not update your'))
    assert_response :success
    assert assigns(:guidance_group)
  end

  # PUT /org/admin/guidancegroup/:id/admin_update_publish (admin_update_publish_guidance_group)
  test 'publish the guidance' do 
    @guidance_group = GuidanceGroup.first

    # Should redirect user to the root path if they are not logged in!
    put admin_update_publish_guidance_group_path(@guidance_group)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_publish_guidance_group_path(@guidance_group)
    assert_response :redirect
    assert flash[:notice].include?('published')
    assert_redirected_to "#{admin_index_guidance_path}"
    assert assigns(:guidance_group)
  end

  # PUT /org/admin/guidancegroup/:id/admin_update_unpublish (admin_update_unpublish_guidance_group)
  test 'unpublish the guidance' do 
    @guidance_group = GuidanceGroup.first

    # Should redirect user to the root path if they are not logged in!
    put admin_update_unpublish_guidance_group_path(@guidance_group)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_unpublish_guidance_group_path(@guidance_group)
    assert_response :redirect
    assert flash[:notice].include?('no longer published')
    assert_redirected_to "#{admin_index_guidance_path}"
    assert assigns(:guidance_group)
  end

  # DELETE /org/admin/guidancegroup/:id/admin_destroy (admin_destroy_guidance_group_path)
  # ----------------------------------------------------------
  test 'delete the guidance_group' do
    id = GuidanceGroup.first.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_guidance_group_path(GuidanceGroup.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_guidance_group_path(GuidanceGroup.first)
    assert_response :redirect
    assert_redirected_to admin_index_guidance_path
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_raise ActiveRecord::RecordNotFound do 
      GuidanceGroup.find(id).nil?
    end
  end
  
end