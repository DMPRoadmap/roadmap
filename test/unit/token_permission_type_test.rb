require 'test_helper'

class TokenPermissionTypeTest < ActiveSupport::TestCase
  
  def setup
    @tpt = token_permission_types(:plans_token_type)
    @org = organisations(:curation_center)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not TokenPermissionType.new.valid?, "was expecting TokenPermissionType.token_type to be required!"
    assert TokenPermissionType.new(token_type: 'testing').valid?, "was only expecting TokenPermissionType.token_type to be required!"
  end
  
  # ---------------------------------------------------
  test "token_type must be unique" do
    assert_not TokenPermissionType.new(token_type: @tpt.token_type).valid?, "was expecting TokenPermissionType.token_type to be unique!"
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    tpt = TokenPermissionType.create(token_type: 'testing')
    assert_not tpt.id.nil?, "was expecting to be able to create a new TokenPermissionType"

    tpt.text_description = 'testing updates'
    tpt.save!
    assert_equal 'testing updates', tpt.reload.text_description, "was expecting the text_description to have been updated!"

    assert tpt.destroy!, "Was unable to delete the TokenPermissionType!"
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Organisation" do
    org = Organisation.new(name: 'Testing')
    verify_has_many_relationship(@tpt, org, @tpt.organisations.count)
  end

end