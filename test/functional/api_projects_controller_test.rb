require 'test_helper'
#require "rack/test"

class ApiProjectsControllerTest < ActionDispatch::IntegrationTest
  #include Rack::Test::Methods

  @controller = Api::V0::ProjectsController.new

  test "create validates that a user has plans auth" do
=begin
    # has auth for projects
    @user = users.first
    post '/create', params: {template:{
                            organisation: "Arts and Humanities Research Council"},
                            project:{title:"my project", email:"org_admin@example.com"}}
    assert_response :success

    # has no auth for projects
    # @user = users(:user_three)
    # post  :create, params: {template:{organisation: "Arts and Humanities Research Council"},project:{title:"my project", email:"org_admin@example.com"}}
    # assert_response 400
=end
  end

  test "create validates that the passed organisation exists" do
  
  end

  test "create validates that the passed organisation is a funder" do

  end

  test "create validates that the passed organisation has only 1 template" do

  end

  test "create validates that a passed organisation with more than one template specifies template" do

  end

  test "create checks for a guidance and adds it if it exists" do

  end

  test "create checks for guidances and adds them if they exist" do

  end

  test "create invites is user email not already in system" do

  end

  test "create creates a new project when params correct" do

  end

end