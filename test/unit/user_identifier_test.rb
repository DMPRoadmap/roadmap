require 'test_helper'

class UserIdentifierTest < ActiveSupport::TestCase
  
  def setup
    @user = User.first
    @scheme = IdentifierScheme.first
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not UserIdentifier.new.valid?
    assert_not UserIdentifier.new(user: @user).valid?
    assert_not UserIdentifier.new(identifier_scheme: @scheme).valid?
    assert_not UserIdentifier.new(identifier: 'TEST').valid?
    assert_not UserIdentifier.new(user: @user, identifier_scheme: @scheme).valid?
    assert_not UserIdentifier.new(user: @user, identifier: 'TEST').valid?
    assert_not UserIdentifier.new(identifier_scheme: @scheme, identifier: 'TEST').valid?
    
    assert UserIdentifier.new(user: @user, identifier_scheme: @scheme, identifier: 'TEST').valid?
  end
  
  # ---------------------------------------------------
  test "can only have one identifier per User/IdentifierScheme" do
    ui = UserIdentifier.create(user: @user, identifier_scheme: @scheme, identifier: 'TEST')
    
    @user.user_identifiers << UserIdentifier.new(identifier_scheme: @scheme, identifier: 'abc')
    
    assert_not @user.valid?, "Expected to NOT be able to add more than one identifier for the same user/scheme"
    assert_equal ui.identifier, @user.user_identifiers.select{ |i| i.identifier_scheme == @scheme }.first.identifier, "Expected the initial identifier to have been retained"
  end
  
end