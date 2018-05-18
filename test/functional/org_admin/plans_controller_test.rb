require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    # Get the first Org Admin
    @org = Org.funder.first
    @admin = User.create!(email: "org-admin-plans-tester@example.com", 
                         firstname: "Org", surname: "Admin",
                         password: "password123", password_confirmation: "password123",
                         org: @org, accept_terms: true, confirmed_at: Time.zone.now)
                         
    # Make sure the user is an org admin
    @admin.perms << Perm.where(name: ['grant_permissions', 'modify_guidance', 
                                      'modify_templates', 'change_org_details'])
    @admin.save!
    
    @regular_user = User.create!(email: 'org_admin_plans_tester@example.com', firstname: "Tester", surname: "Testing",
                                 password: "password123", password_confirmation: "password123",
                                 org: @org, accept_terms: true, confirmed_at: Time.zone.now, ) 
    @plan = Plan.create!(template: Template.first, title: 'Test Plan', visibility: :privately_visible, feedback_requested: true,
                         roles: [Role.new(user: @regular_user, creator: true)])
    Role.create!(user: @admin, plan: @plan, access: Role.access_values_for(:reviewer).min)
  end

  test "unauthorized user cannot access the plans page" do
    # Should redirect user to the root path if they are not logged in!
    get org_admin_plans_path
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get org_admin_plans_path
    assert_authorized_redirect_to_plans_page
  end
  
  test "org admin can access the plans page" do
    sign_in @admin
    get org_admin_plans_path

    assert_response :success
    assert assigns(:plans)
    assert assigns(:feedback_plans)
  end

  test "unauthorized user cannot complete feedback" do
    # Should redirect user to the root path if they are not logged in!
    get org_admin_plans_path
    get feedback_complete_org_admin_plan_path(@plan)
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get feedback_complete_org_admin_plan_path(@plan)
    assert_authorized_redirect_to_plans_page
  end
  
  test "org admin can complete feedback" do
    sign_in @admin
    get feedback_complete_org_admin_plan_path(@plan)
    assert_response :redirect
    
    # TODO: This one is failing on Travis but not on any other machine
    #       seems to be due to the seeds.rb not loading properly on the
    #       latest instance of Travis
    #assert_redirected_to org_admin_plans_path
  end
  
  test "unauthorized user cannot download the plans as CSV" do
    # Should redirect user to the root path if they are not logged in!
    get org_admin_download_plans_path(format: :csv)
    assert_unauthorized_redirect_to_root_path
    # Non Org-Admin cannot perform this action
    sign_in @regular_user
    get org_admin_download_plans_path(format: :csv)
    assert_authorized_redirect_to_plans_page
  end
  
  test "org admin can download plans as CSV" do
    sign_in @admin
    get org_admin_download_plans_path(format: :csv)
    assert_response :success
  end

end