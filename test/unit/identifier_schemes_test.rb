require 'test_helper'

class IdentifierSchemesTest < ActiveSupport::TestCase

  def setup
    @scheme = IdentifierScheme.first
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not IdentifierScheme.new.valid?
    assert_not IdentifierScheme.new(domain: 'example.org').valid?
    
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
  test "landing_page_uri must be a valid url" do
    assert_not IdentifierScheme.new(name: 'testing', landing_page_uri: 'example.org').valid?
    assert_not IdentifierScheme.new(name: 'testing', landing_page_uri: 'ehgegg://wrgfre.example.org').valid?
    assert_not IdentifierScheme.new(name: 'testing', landing_page_uri: 'http://example/dir/page').valid?
    assert_not IdentifierScheme.new(name: 'testing', landing_page_uri: 'file://example.org/file/name.txt').valid?
    
    assert IdentifierScheme.new(name: 'testing', landing_page_uri: 'http://example.org').valid?
    assert IdentifierScheme.new(name: 'testing', landing_page_uri: 'https://example.org').valid?
    assert IdentifierScheme.new(name: 'testing', landing_page_uri: 'http://example.org/path/page').valid?
    assert IdentifierScheme.new(name: 'testing', landing_page_uri: 'http://example.org/path/page?p=1&r=2').valid?
    assert IdentifierScheme.new(name: 'testing', landing_page_uri: 'http://example.org/path/page?p=abc%2F').valid?
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    is = IdentifierScheme.create(name: 'testing')
    assert_not is.id.nil?, "was expecting to be able to create a new IdentifierScheme: #{is.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    is.api_key = 'Testing It Out'
    is.save!
    is.reload
    assert_equal 'Testing It Out', is.api_key, "Was expecting to be able to update the api_key of the IdentifierScheme!"
    
    assert is.destroy!, "Was unable to delete the IdentifierScheme!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Users" do
    usr = User.new(email: 'me@example.edu', password: 'password')
    verify_has_many_relationship(@scheme, usr, @scheme.users.count)
  end

end
