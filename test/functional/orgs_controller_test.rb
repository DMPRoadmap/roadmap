require 'test_helper'

class OrgsControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  # TODO: The following methods SHOULD replace the old 'admin_' prefixed methods. The children_org and templates_org
  #       routes don't even have an endpoint defined in the controller!
  #
  # SHOULD BE:
  # --------------------------------------------------
  #   orgs      GET    /orgs        orgs#index
  #             POST   /orgs        orgs#create
  #   org       GET    /orgs/:id    orgs#show
  #             PATCH  /orgs/:id    orgs#update
  #             PUT    /orgs/:id    orgs#update
  #             DELETE /orgs/:id    orgs#destroy
  #
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   children_org      GET      /org/admin/:id/children        orgs#children
  #   templates_org     GET      /org/admin/:id/templates       orgs#templates
  #   admin_show_org    GET      /org/admin/:id/admin_show      orgs#admin_show
  #   admin_edit_org    GET      /org/admin/:id/admin_edit      orgs#admin_edit
  #   admin_update_org  PUT      /org/admin/:id/admin_update    orgs#admin_update
  
  setup do
    @org = Org.first
    scaffold_org_admin(@org)
  end

  # GET /org/admin/:id/admin_edit (admin_edit_org_path)
  # ----------------------------------------------------------
  test 'load the edit org page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_edit_org_path(@org)
    assert_response :success
    assert assigns(:org)
    assert assigns(:languages)
  end
  
  # PUT /org/admin/:id/admin_update (admin_update_org_path)
  # ----------------------------------------------------------
  test 'update the org' do
    params = {name: 'Testing UPDATE'}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_org_path(@org), {org: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    put admin_update_org_path(@org), {org: params}
    assert flash[:notice].start_with?('Successfully') && flash[:notice].include?('saved')
    assert_response :success
    assert assigns(:org)
    assert_equal 'Testing UPDATE', @org.reload.name, "expected the record to have been updated"
    
    # Invalid object
    put admin_update_org_path(@org), {org: {contact_email: 'abcdefg'}}
    assert flash[:alert].starts_with?(_('Could not update your'))
    assert_response :success
    assert assigns(:org)
  end
end
