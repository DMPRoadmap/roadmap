require 'test_helper'

class RolesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_plan
    scaffold_org_admin(@plan.template.org)
    
    @invitee = User.last
  end

# TODO: Cleanup routes for this one. The controller currently only responds to create, update, destroy

# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   roles   POST     /roles         roles#create
#   role    PATCH    /roles/:id     roles#update
#           PUT      /roles/:id     roles#update
#           DELETE   /roles/:id     roles#destroy
  
# POST /roles (roles_path)
  # ----------------------------------------------------------
  test "create a new role" do
    params = {email: @invitee.email, plan_id: @plan.id, access_level: 1}
    
    # Should redirect user to the root path if they are not logged in!
    post roles_path, {role: params}
    assert_unauthorized_redirect_to_root_path
    
puts @plan.owner.inspect
    
    sign_in @plan.owner
    
    post roles_path, {role: params}
    assert_equal _('User added to project'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_equal @invitee.id, Role.last.user_id, "expected the record to have been created!"
    assert assigns(:role)
    
    # Missing email
    post roles_path, {role: {plan_id: @plan.id, access_level: 2}}
    assert_equal _('Please enter an email address'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert assigns(:role)
    
    # Invalid object
    post roles_path, {role: {email: @invitee.email, access_level: 2}}
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert assigns(:role)
  end 
  
  # PUT /role/:id (role_path)
  # ----------------------------------------------------------
  test "update the role" do
    role = Role.create(user: @invitee, plan: @plan, access_level: 1)
    params = {access_level: 2}
    
    # Should redirect user to the root path if they are not logged in!
    put role_path(role), {role: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put role_path(role), {role: params}
    assert_equal _('Sharing details successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert assigns(:role)
    assert_equal 'Phase - UPDATE', @phase.sections.first.title, "expected the record to have been updated"
    
    # Invalid save
    put role_path(role), {role: {access_level: nil}}
    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert assigns(:role)
  end
  
  # DELETE /role/:id (role_path)
  # ----------------------------------------------------------
  test "delete the section" do
    role = Role.create(user: @invitee, plan: @plan, access_level: 1)
    
    # Should redirect user to the root path if they are not logged in!
    delete role_path(role)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete role_path(role)
    assert_equal _('Access removed'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_raise ActiveRecord::RecordNotFound do 
      Role.find(role.id).nil?
    end
  end
  
end