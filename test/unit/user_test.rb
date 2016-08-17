require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:with_many_projects)
  end

  test "User#projects behaves the same as Project.projects_for_user" do
    # FIXME: Is the ordering important? If so, don't mask the different orders here!
    user_projects = @user.projects.pluck(:id).sort
    projects_for_user = Project.projects_for_user(@user.id).collect {|p| p.id}.sort

    assert_not_empty(user_projects)
    assert_equal(user_projects, projects_for_user)
  end

  test "empty filter term returns all projects" do
    projects = @user.projects
    filtered = @user.projects.filter('')

    assert_not_empty(projects)
    assert_equal(projects, filtered)
  end

  test "nil filter term returns all projects" do
    projects = @user.projects
    filtered = @user.projects.filter(nil)

    assert_not_empty(projects)
    assert_equal(projects, filtered)
  end

  test "valid filter term only returns matching records" do
    projects = @user.projects
    filtered = @user.projects.filter('DCC')

    assert_equal(filtered.count, 1)
    assert_not_equal(filtered, projects)
    assert_equal(projects(:test_plan_3), filtered.first)
  end

end
