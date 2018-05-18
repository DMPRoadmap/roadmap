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
    @test_org = Org.create!(name: 'Testing', abbreviation: 'TST', links: {"org":[]})
    @admin = User.create!(email: "org-admin-controller-test@example.com", firstname: "Org", surname: "Admin",
                         password: "password123", password_confirmation: "password123",
                         org: @test_org, accept_terms: true, confirmed_at: Time.zone.now,
                         perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs', 'change_org_details']))
    @admin.perms << Perm.find_by(name: 'change_org_details')
    @admin.perms << Perm.find_by(name: 'modify_templates')
    @admin.perms << Perm.find_by(name: 'modify_guidance')
    @admin.perms << Perm.find_by(name: 'grant_permissions')
    @admin.save!
  end

  # GET /org/admin/:id/admin_edit (admin_edit_org_path)
  # ----------------------------------------------------------
  test 'load the edit org page' do
    # Should redirect user to the root path if they are not logged in!
    get admin_edit_org_path(@test_org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @admin
    get admin_edit_org_path(@test_org)
    assert_response :success
  end
  
  # PUT /org/admin/:id/admin_update (admin_update_org_path)
  # ----------------------------------------------------------
  test 'update the org' do
    params = {name: 'Testing UPDATE', links: {"org": []}}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_org_path(@test_org), {org: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @admin
    put admin_update_org_path(@test_org), {org: params}
    assert_response :redirect
    assert_equal 'Testing UPDATE', @test_org.reload.name, "expected the record to have been updated"
  end
end
