require 'test_helper'

class IdentifierSchemesTest < ActiveSupport::TestCase

  def setup
    @scheme = IdentifierScheme.first
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not IdentifierScheme.new.valid?
    assert_not IdentifierScheme.new(description: 'we are testing').valid?
    
    # Ensure that the bare minimum of fields is still valid
    assert IdentifierScheme.new(name: 'testing').valid?
  end

  # ---------------------------------------------------
  test "name must be unique" do
    assert_not IdentifierScheme.new(name: @scheme.name).valid?
    
    # Ensure that the bare minimum of fields is still valid
    assert IdentifierScheme.new(name: 'testing').valid?
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    is = IdentifierScheme.create(name: 'testing')
    assert_not is.id.nil?, "was expecting to be able to create a new IdentifierScheme: #{is.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    is.description = 'Testing It Out'
    is.save!
    is.reload
    assert_equal 'Testing It Out', is.description, "Was expecting to be able to update the api_key of the IdentifierScheme!"
    
    assert is.destroy!, "Was unable to delete the IdentifierScheme!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with UserIdentifiers" do
    ui = UserIdentifier.new(user: User.first, identifier: 'tester')
    verify_has_many_relationship(@scheme, ui, @scheme.users.count)
  end

end
