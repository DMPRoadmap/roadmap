require 'test_helper'

class UserIdentifiersControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @user = User.first
  end

# CURRENT RESULTS OF `rake routes`
# --------------------------------------------------
#   destroy_user_identifier   DELETE   /users/identifiers/:id     user_identifiers#destroy
  
  
  # DELETE /users/identifiers/:id (destroy_user_identifier_path)
  # ----------------------------------------------------------
  test "delete the section" do
    ui = UserIdentifier.create(user: @user, identifier_scheme: IdentifierScheme.first, identifier: 'TESTING')

    # Should redirect user to the root path if they are not logged in!
    delete destroy_user_identifier_path(ui)
    assert_unauthorized_redirect_to_root_path
    
    sign_in @user
    
    delete destroy_user_identifier_path(ui)
    assert flash[:notice].start_with?(_('Successfully unlinked your account from')), "expected the success message"
    assert_response :redirect
    assert_redirected_to edit_user_registration_path
    assert_raise ActiveRecord::RecordNotFound do 
      UserIdentifier.find(ui.id).nil?
    end
  end
  
end