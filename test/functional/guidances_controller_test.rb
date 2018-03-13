require 'test_helper'

class GuidancesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers

  # TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
  #       these defined. They are defined multiple times though and we need to clean this up:
  #
  # SHOULD BE:
  # --------------------------------------------------
  #   guidances            GET    /guidances        guidances#index
  #                        POST   /guidances        guidances#create
  #   guidance             GET    /guidance/:id     guidances#show
  #                        PATCH  /guidance/:id     guidances#update
  #                        PUT    /guidance/:id     guidances#update
  #                        DELETE /guidance/:id     guidances#destroy
  #
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   admin_show_guidance       GET      /org/admin/guidance/:id/admin_show           guidances#admin_show
  #   admin_index_guidance      GET      /org/admin/guidance/:id/admin_index          guidances#admin_index
  #   admin_edit_guidance       GET      /org/admin/guidance/:id/admin_edit           guidances#admin_edit
  #   admin_new_guidance        GET      /org/admin/guidance/:id/admin_new            guidances#admin_new
  #   admin_destroy_guidance    DELETE   /org/admin/guidance/:id/admin_destroy        guidances#admin_destroy
  #   admin_create_guidance     POST     /org/admin/guidance/:id/admin_create         guidances#admin_create
  #   admin_update_guidance     PUT      /org/admin/guidance/:id/admin_update         guidances#admin_update
  #   update_phases_guidance    GET      /org/admin/guidance/:id/update_phases        guidances#update_phases
  #   update_versions_guidance  GET      /org/admin/guidance/:id/update_versions      guidances#update_versions
  #   update_sections_guidance  GET      /org/admin/guidance/:id/update_sections      guidances#update_sections
  #   update_questions_guidance GET      /org/admin/guidance/:id/update_questions     guidances#update_questions

  setup do
    scaffold_org_admin(GuidanceGroup.first.org)
    @guidance_group = GuidanceGroup.first
  end
  
  # GET /org/admin/guidance/:id/admin_index (admin_index_guidance_path)
  # ----------------------------------------------------------
  test 'load the list of guidances page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_index_guidance_path(@guidance_group)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_index_guidance_path(@guidance_group)
    assert_response :success
    assert assigns(:guidances)
    assert assigns(:guidance_groups)
  end
  
  # /org/admin/guidance/:id/admin_new (admin_new_guidance_path)
  # ----------------------------------------------------------
  test 'load the new guidance page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_new_guidance_path(@guidance_group)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_new_guidance_path(@guidance_group)
    assert_response :success
  end

  # /org/admin/guidance/:id/admin_edit (admin_edit_guidance_path)
  # ----------------------------------------------------------
  test 'load the edit guidance page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_guidance_path(@guidance_group)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_guidance_path(@guidance_group)
    assert_response :success
  end

  # POST /org/admin/guidance/:id/admin_create (admin_create_guidance_path)
  # ----------------------------------------------------------
  test 'create a new guidance' do
    params = {'guidance-text': 'Testing create', guidance: {guidance_group_id: GuidanceGroup.first.id, published: true}}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_guidance_path(@user.org), params
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_guidance_path(@user.org), params
    assert_response :redirect
    assert_redirected_to admin_index_guidance_path
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('created')
    assert_equal 'Testing create', Guidance.last.text, "expected the record to have been created!"
    
    # Invalid object
    post admin_create_guidance_path(@user.org), {'guidance-text': nil, guidance: {published: false}}
    assert flash[:alert].starts_with?(_('Could not create your'))
    assert_response :redirect
    assert_redirected_to admin_index_guidance_path
  end
    
  # PUT /org/admin/guidance/:id/admin_update (admin_update_guidance_path)
  # ----------------------------------------------------------
  test 'update the guidance' do
    params = {'guidance-text': 'Testing UPDATE', guidance: {guidance_group_id: GuidanceGroup.first.id}}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_guidance_path(Guidance.first), params
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_guidance_path(Guidance.first), params
    assert_response :redirect
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_redirected_to admin_index_guidance_path
    assert_equal 'Testing UPDATE', Guidance.first.text, "expected the record to have been updated"
    
    # Invalid object
    put admin_update_guidance_path(Guidance.first), {'guidance-text': nil, guidance: {guidance_group_id: GuidanceGroup.first.id}}
    assert flash[:alert].starts_with?(_('Could not update your'))
    assert_response :redirect
    assert_redirected_to admin_edit_guidance_path(Guidance.first)
  end

  # PUT /org/admin/guidance/:id/admin_publish (admin_publish_guidance)
  test 'publish the guidance' do 
    @guidance = Guidance.first
    @guidance_group = @guidance.guidance_group

    # Should redirect user to the root path if they are not logged in!
    put admin_publish_guidance_path(@guidance)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_publish_guidance_path(@guidance)
    assert_response :redirect
    assert flash[:notice].include?('published')
    assert_redirected_to "#{admin_index_guidance_path}"
  end

  # PUT /org/admin/guidance/:id/admin_unpublish (admin_unpublish_guidance)        
  test 'unpublish the guidance' do 
    @guidance = Guidance.first
    @guidance_group = @guidance.guidance_group

    # Should redirect user to the root path if they are not logged in!
    put admin_unpublish_guidance_path(@guidance)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_unpublish_guidance_path(@guidance)
    assert_response :redirect
    assert flash[:notice].include?('no longer published')
    assert_redirected_to "#{admin_index_guidance_path}"
  end

  # DELETE /org/admin/guidance/:id/admin_destroy (admin_destroy_guidance_path)
  # ----------------------------------------------------------
  test 'delete the guidance' do
    id = Guidance.first.id
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_guidance_path(Guidance.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_guidance_path(Guidance.first)
    assert_response :redirect
    assert_redirected_to admin_index_guidance_path
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('deleted')
    assert_raise ActiveRecord::RecordNotFound do 
      Guidance.find(id).nil?
    end
  end

end