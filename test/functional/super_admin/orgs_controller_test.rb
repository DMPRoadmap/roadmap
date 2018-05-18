require 'test_helper'

class OrgsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  
  setup do
    @org = Org.first
    @super_admin = User.find_by(email: 'super_admin@example.com')
  end

  test 'unauthorized user cannot access index page' do
    get super_admin_orgs_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in User.where.not(id: @super_admin.id).first
    get super_admin_orgs_path
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can access index page' do  
    sign_in @super_admin
    get super_admin_orgs_path
    assert_response :success
  end

  test 'unauthorized user cannot access new org page' do
    get new_super_admin_org_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in User.where.not(id: @super_admin.id).first
    get new_super_admin_org_path
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can access new org page' do  
    sign_in @super_admin
    get new_super_admin_org_path
    assert_response :success
  end
  
  test 'unauthorized user cannot create an org' do
    params = {name: 'Test Org', abbreviation: 'ABCD'}
    post super_admin_orgs_path, {org: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in User.where.not(id: @super_admin.id).first
    post super_admin_orgs_path, {org: params}
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can create an org' do  
    params = {name: 'Test Org create', abbreviation: 'ABCD'}
    sign_in @super_admin
    
    post super_admin_orgs_path, {org: params}
    assert_response :redirect
  end

  test 'unauthorized user cannot destroy an org' do
    delete super_admin_org_path(@org)
    assert_unauthorized_redirect_to_root_path
    
    sign_in User.where.not(id: @super_admin.id).first
    delete super_admin_org_path(@org)
    assert_authorized_redirect_to_plans_page
  end

  test 'super admin can destroy an org' do  
    org = Org.create!(name: 'Testing destroy', abbreviation: 'TST', links: {"org":[]})
    sign_in @super_admin

    delete super_admin_org_path(org)
    assert_response :redirect
    assert_redirected_to super_admin_orgs_path
    assert_not flash[:notice].nil?
  end
end
