require 'test_helper'

class TokenPermissionTypesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  # CURRENT RESULTS OF `rake routes`
  # --------------------------------------------------
  #   token_permission_types  GET      /token_permission_types        token_permission_types#index
  
  setup do
    @user = User.first
  end
  
  # GET /token_permission_types (token_permission_types_path)
  # ----------------------------------------------------------
  test "retrieve the list of token permission types" do
    # Should redirect user to the root path if they are not logged in!
    get token_permission_types_path
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    get token_permission_types_path
    assert_response :success
    assert assigns(:user)
    assert assigns(:token_types)
  end
  
end