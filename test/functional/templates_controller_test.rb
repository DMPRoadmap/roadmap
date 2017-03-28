class TemplatesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_template
    
    # Get the first Org Admin
    @user = User.where(org: @template.org).select{|u| u.can_org_admin?}.first
  end

# TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The routes file already has
#       these defined. We should remove the old routes to the 'admin_' prefixed methods as well

  # GET /admin/templates (admin_templates_path)
  # ----------------------------------------------------------
  test "get list of all templates" do
    # TODO: This method should replace admin_index and would ideally be `templates GET`
  end 
  
  # POST /admin/templates (admin_templates_path)
  # ----------------------------------------------------------
  test "create a new template" do
    # TODO: This method should replace admin_create and would ideally be `templates POST`
  end 
  
  # GET /admin/templates/new (new_admin_template_path)
  # ----------------------------------------------------------
  test "get the new template page" do
    # TODO: This method should replace admin_new and would ideally be `templates/new GET`
  end
  
  # GET /admin/templates/:id/edit (edit_admin_template_path)
  # ----------------------------------------------------------
  test "get the edit template page" do
    # TODO: This method should replace admin_edit and would ideally be `templates/[:id]/edit GET`
  end 
  
  # GET /admin/templates/:id (admin_template_path)
  # ----------------------------------------------------------
  test "get the show template page" do
    # TODO: This method should replace admin_show and would ideally be `template/[:id] GET`
  end 
  
  # PUT/PATCH /admin/templates/:id (admin_template_path)
  # ----------------------------------------------------------
  test "update the template" do
    # TODO: This method should replace admin_update and would ideally be `template/[:id] PUT`
  end 
  
  # DELETE /admin/templates/:id (admin_template_path)
  # ----------------------------------------------------------
  test "destroy the template" do
    # TODO: This method should replace admin_destroy and would ideally be `template/[:id] DELETE`
  end 
  
  
  
  
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
    
    assert assigns(:template)
  end
  
  # GET /org/admin/templates/:id/admin_update (admin_update_template_path)
  # ----------------------------------------------------------
  test "update the admin template" do
    sign_in @user

  end

end