require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers

  setup do
    scaffold_org_admin(Org.last)
  end
  
  # TODO: Reassess these routes. Devise handles the standard profile pages so defining a more RESTful setup
  #       wouldn't conflict with the update/create of the main user object. They should probably be something like:
  #
  #   users                         GET   /org/:org_id/users      users#index
  #   user                          GET   /user/:id               users#show
  #   user                          PUT   /user/:id               users#update
  
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   admin_index_users             GET   /org/admin/users/admin_index                  users#admin_index
  #   admin_grant_permissions_user  GET   /org/admin/users/:id/admin_grant_permissions  users#admin_grant_permissions
  #   admin_update_permissions_user PUT   /org/admin/users/:id/admin_update_permissions users#admin_update_permissions


  # GET /org/admin/users/admin_index (admin_index_users_path)
  # ----------------------------------------------------------
  test "get the list of users" do
    # Should redirect user to the root path if they are not logged in!
    get admin_index_users_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
puts "USER: #{@user.org.inspect}"
puts "ORG: #{Org.last.inspect}"
    
    get admin_index_users_path
    assert_response :success
    assert assigns(:users)
  end
  
  # GET /org/admin/users/:id/admin_grant_permissions (admin_grant_permissions_user_path)
  # ----------------------------------------------------------
  test "grant the user's permissions" do
    # Should redirect user to the root path if they are not logged in!
    get admin_grant_permissions_user_path(@user.org.users.first)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get admin_grant_permissions_user_path(@user.org.users.first)
    assert_response :success
    assert assigns(:user)
    assert assigns(:perms)
  end

  # PUT /org/admin/users/:id/admin_update_permissions (admin_update_permissions_user_path)
  # ----------------------------------------------------------
  test "update the user's permissions" do
    params = {perm_ids: [Perm.last.id, Perm.first.id]}
    
    # Should redirect user to the root path if they are not logged in!
    put admin_update_permissions_user_path(@user.org.users.last), {user: params}
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user

    # Valid save
    put admin_update_permissions_user_path(@user.org.users.last), {user: params}
    assert_equal _('Information was successfully updated.'), flash[:notice]
    assert_response :redirect
    assert_redirected_to admin_index_users_url
    @user.org.users.last.perms.each do |perm|
      assert params[:perm_ids].include?(perm.id), "did not expect to find the #{perm.name} attached to the user"
    end
  end
end
