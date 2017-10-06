require 'test_helper'

class RolesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_plan
    scaffold_org_admin(@plan.template.org)

    # This should NOT be unnecessary! Owner should have full access
    @plan.roles << Role.create(user: @user, plan: @plan, access: 15)

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

    params = {plan_id: @plan.id, access_level: 4}

    # Should redirect user to the root path if they are not logged in!
    post roles_path, {role: params}
    assert_unauthorized_redirect_to_root_path

    sign_in @user

    # Known user
    @invitee = User.where.not(id: [@plan.owner.id, @user.id]).first
    post roles_path, {user: @invitee.email, role: params}
    assert_equal _('Plan shared with %{email}.') % {email: @invitee.email}, flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_equal @invitee.id, Role.last.user_id, "expected the record to have been created!"
    assert assigns(:role)

    # Share to already invited user
    post roles_path, {user: @invitee.email, role: params}
    assert_equal _('Plan is already shared with %{email}.') % {email: @invitee.email}, flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_equal @invitee.id, Role.last.user_id, "expected no record to have been created!"
    assert assigns(:role)

    # Unknown user
    post roles_path, {user: 'unknown_user@org.org', role: params}
    assert_equal _('Invitation to unknown_user@org.org issued successfully. \nPlan shared with unknown_user@org.org.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_equal User.find_by(email:'unknown_user@org.org').id, Role.last.user_id, "expected the record to have been created!"
    assert assigns(:role)

    # Invite owner
    @invitee = User.find_by(id: @plan.owner.id)
    post roles_path, {user: @invitee.email, role: params}
    assert_equal _('Cannot share plan with %{email} since that email matches with the owner of the plan.') % {email: @invitee.email}, flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert_not_equal @invitee.id, Role.last.user_id, "expected no record to have been created!"
    assert assigns(:role)

    # Missing email
    post roles_path, {role: {plan_id: @plan.id, access_level: 4}}
    assert_equal _('Please enter an email address'), flash[:notice]
    assert_response :redirect
    assert_redirected_to share_plan_path(@plan)
    assert assigns(:role)
  end

  # PUT /role/:id (role_path)
  # ----------------------------------------------------------
  test "update the role" do
    @invitee = User.last
    role = Role.create(user: @invitee, plan: @plan, access: 1)
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
    assert_equal 13, role.reload.access, "expected the record to have been updated"

# TODO: Role should require a user, plan and an access level :/
    # Invalid save
#    put role_path(role), {role: {user: nil}}
#    assert flash[:notice].starts_with?(_('Unable to save your changes.'))
#    assert_response :redirect
#    assert_redirected_to share_plan_path(@plan)
#    assert assigns(:role)
  end

  # DELETE /role/:id (role_path)
  # ----------------------------------------------------------
  test "delete the section" do
    @invitee = User.last
    role = Role.create(user: @invitee, plan: @plan, access: 1)

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
