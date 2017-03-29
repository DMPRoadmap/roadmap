class TemplatesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    
    # Get the first Org Admin
    @user = org_admin_from(Template.first.org)
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. We should remove the old routes to the 'admin_' prefixed methods as well. We should just
#       have:
#
# SHOULD BE:
# --------------------------------------------------
#   templates               GET    /templates           templates#index
#                           POST   /templates           templates#create
#   template                GET    /template/[:id]      templates#show
#                           PATCH  /template/[:id]      templates#update
#                           PUT    /template/[:id]      templates#update
#                           DELETE /template/[:id]      templates#destroy
#   edit_template           GET    /template/[:id]/edit templates#edit
#   new_template            GET    /templates/new       templates#new
#
#
# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   admin_index_template    GET    /org/admin/templates/:id/admin_index(.:format)          templates#admin_index
#   admin_template_template GET    /org/admin/templates/:id/admin_template(.:format)       templates#admin_template
#   admin_new_template      GET    /org/admin/templates/:id/admin_new(.:format)            templates#admin_new
#   admin_template_history_template GET /org/admin/templates/:id/admin_template_history(.:format) templates#admin_template_history
#   admin_destroy_template  DELETE /org/admin/templates/:id/admin_destroy(.:format)        templates#admin_destroy
#   admin_create_template   POST   /org/admin/templates/:id/admin_create(.:format)         templates#admin_create
#   admin_update_template   PUT    /org/admin/templates/:id/admin_update(.:format)         templates#admin_update
  
  
  # GET /org/admin/templates/:id/admin_index (admin_index_template_path) the :id here makes no sense!
  # ----------------------------------------------------------
  test "get the list of admin templates" do
    # Should redirect user to the root path if they are not logged in!
    get admin_index_template_path(@user.org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_index_template_path(@user.org)
    assert_response :success
    
    assert assigns(:templates_own)
    assert assigns(:other_published_version)
    assert assigns(:templates_funders)
    assert assigns(:templates_customizations)
  end 
  
  # GET /org/admin/templates/:id/admin_template (admin_template_template_path)
  # ----------------------------------------------------------
  test "get the admin template" do
    # Should redirect user to the root path if they are not logged in!
    get admin_template_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_template_template_path(@template)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:hash)
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # GET /org/admin/templates/:id/admin_new (admin_new_template_path)
  # ----------------------------------------------------------
  test "get the new admin template page" do
    # Should redirect user to the root path if they are not logged in!
    get admin_new_template_path(Template.last.id)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_new_template_path(Template.last.id)
    assert_response :success
  end
  
  # GET /org/admin/templates/:id/admin_template_history (admin_template_history_template_path)
  # ----------------------------------------------------------
  test "get the admin template history page" do
    # Should redirect user to the root path if they are not logged in!
    get admin_template_history_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_template_history_template_path(@template)
    assert_response :success
    
    assert assigns(:template)
    assert assigns(:templates)
  end
  
  # DELETE /org/admin/templates/:id/admin_destroy (admin_destroy_template_path)
  # ----------------------------------------------------------
  test "delete the admin template" do
    # Should redirect user to the root path if they are not logged in!
    delete admin_destroy_template_path(@template)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete admin_destroy_template_path(@template)
    assert_response :redirect
    assert_redirected_to admin_index_template_url
  end
  
#  TODO: Why are we passing an :id here!? Its a new record but we seem to need the last template's id
  # POST /org/admin/templates/:id/admin_create (admin_create_template_path)
  # ----------------------------------------------------------
  test "create a admin template" do
    params = {org_id: @user.org.id, version: 0, title: 'Testing create route'}
    
    # Should redirect user to the root path if they are not logged in!
    post admin_create_template_path(Template.last.id), {template: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    post admin_create_template_path(Template.last.id), {template: params}
    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last.id)
    assert_equal _('Information was successfully created.'), flash[:notice]
    assert assigns(:template)
    
    # Invalid object
    post admin_create_template_path(Template.last.id), {template: {title: nil, org_id: @user.org.id}}
    assert_response :success
    assert assigns(:template)
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
  end
  
  # GET /org/admin/templates/:id/admin_update (admin_update_template_path)
  # ----------------------------------------------------------
  test "update the admin template" do
    params = {title: 'ABCD'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_template_path(@template), {template: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Make sure we get the proper message if trying to update a published template
    put admin_update_template_path(@template), {template: params}
    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last.id)
    assert_equal _('Published templates cannot be edited.'), flash[:notice]
    assert assigns(:template)
    
    @template.published = false
    @template.save!
    
    # Make sure we get the right response when editing an unpublished template
    put admin_update_template_path(@template), {template: params}
    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last.id)
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert assigns(:template)
    
    # Make sure we get the right response when providing an invalid template
    put admin_update_template_path(@template), {template: {title: nil}}
    assert_response :redirect
    assert_redirected_to admin_template_template_url(Template.last.id)
    assert assigns(:template)
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
  end

end