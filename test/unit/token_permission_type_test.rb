require 'test_helper'

class TokenPermissionTypeTest < ActiveSupport::TestCase
  
  def setup
    @tpt = TokenPermissionType.create(token_type: 'testing', text_description: 'abcd')
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not TokenPermissionType.new.valid?, "was expecting TokenPermissionType.token_type to be required!"
    assert TokenPermissionType.new(token_type: 'tester').valid?, "was only expecting TokenPermissionType.token_type to be required!"
  end
  
  # ---------------------------------------------------
  test "token_type must be unique" do
    assert_not TokenPermissionType.new(token_type: @tpt.token_type).valid?, "was expecting TokenPermissionType.token_type to be unique!"
  end
  
  # ---------------------------------------------------
  test "to_s returns the token_type" do
    assert_equal @tpt.token_type, @tpt.to_s
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    tpt = TokenPermissionType.create(token_type: 'tester')
    assert_not tpt.id.nil?, "was expecting to be able to create a new TokenPermissionType - #{tpt.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    tpt.text_description = 'testing updates'
    tpt.save!
    assert_equal 'testing updates', tpt.reload.text_description, "was expecting the text_description to have been updated!"

    assert tpt.destroy!, "Was unable to delete the TokenPermissionType!"
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Org" do
    org = Org.new(name: 'Testing', links: {"org":[]})
    verify_has_many_relationship(@tpt, org, @tpt.orgs.count)
  end

end