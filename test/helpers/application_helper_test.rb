require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  
  def setup
    # initialize the ActionView Output so that we have access to its functions (e.g. content_for)
    @view_flow = ActionView::OutputFlow.new
    
    content_for(:head) do
      "<title>Testing</title>".html_safe
    end
  end
  
  # -----------------------------------------------------------------------
  test "resource_name should return :user" do
    assert_equal :user, resource_name
  end
  
  # -----------------------------------------------------------------------
  test "resource should return contents of instance variable @resource OR a new User" do
    # If @resource is not set then we should receive a new User
    assert resource.is_a?(User), "Expected resource() to return a new User"
    assert_nil resource.id, "Expected resource() to return a User with an Id"
    
    # If @resource is set then we should receive that object
    @resource = Org.first
    assert resource.is_a?(Org), "Expected resource() to return @resource"
    assert_equal @resource.id, resource.id, "Expected resource() to return the first Organisation"
  end
  
  # -----------------------------------------------------------------------
  test "devise_mapping should return the mappings registered for Devise" do
    # If @devise_mappings is not set we should get the mappings for :user
    assert_equal Devise.mappings[:user], devise_mapping, "Expected devise_mapping() to return the correct default"

    # If @devise_mapping is set the we should receive it
    @devise_mapping = {foo: 'bar'}
    assert_equal @devise_mapping, devise_mapping, "Expected devise_mapping() to return @devise_mapping"
  end
  
  # -----------------------------------------------------------------------
  test "hash_to_js_json_variable should return valid JSON markup for the specified Hash object" do
    actual = hash_to_js_json_variable('hasher', {foo: 'bar', abc: '123'})
    
    assert actual.include?('script'), "Expected the result to be contained within a script tag but got: #{actual}"
    assert actual.include?('var hasher = '), "Expected the hash to appear as a variable but got: #{actual}"
    assert actual.include?('{"foo":"bar","abc":"123"}'), "Expected the hash contents to appear but got: #{actual}"
  end
end