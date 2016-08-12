require 'test_helper'
require "rack/test"

class ApiProjectsControllerTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    MyApp.new
  end

  @controller = Api::V0::ProjectsController.new

  test "create validates that a user has plans auth" do
    # has auth for projects
    @user = users(:user_dcc)
    post :create, params: {template:{organisation: "Arts and Humanities Research Council"},project:{title:"my project", email:"org_admin@example.com"}}
    assert_response :success

    # has no auth for projects
    # @user = users(:user_three)
    # post  :create, params: {template:{organisation: "Arts and Humanities Research Council"},project:{title:"my project", email:"org_admin@example.com"}}
    # assert_response 400
  end

  test "create validates that the passed organisation exists" do
    flunk
  end

  test "create validates that the passed organisation is a funder" do
    flunk
  end

  test "create validates that the passed organisation has only 1 template" do
    flunk
  end

  test "create validates that a passed organisation with more than one template specifies template" do
    flunk
  end

  test "create checks for a guidance and adds it if it exists" do
    flunk
  end

  test "create checks for guidances and adds them if they exist" do
    flunk
  end

  test "create invites is user email not already in system" do
    flunk
  end

  test "create creates a new project when params correct" do
    flunk
  end

end