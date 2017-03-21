require "test_helper"

# describe "GuidanceGroupsController" do
#   describe "GET :index" do
#     before do
#       get :index
#     end

#     it "renders items/index" do
#       must_render_template "items/index"
#     end

#     it "responds with success" do
#       must_respond_with :success
#     end
#   end
# end
#


class GuidanceGroupsTest < ActionDispatch::IntegrationTest #ActiveSupport::TestCase
  setup do
    @guidance_group = guidance_groups(:one)
  end

=begin
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should show a Guidance Group" do
    get :show, id: @guidance_group
    assert_response :success
  end
=end

  # BASIC AUTH
  # should not respond to incorrect api_tokens
  #
  # should not respond to correct api_tokens with incorrect permissions
  # i.e. their permissions for token include "guidance"
  #
  # INDEX
  # should not respond with non-viewable guidance groups for a user
  #
  # should respond with all viewable guidance groups for a user
  #
  # SHOW
  # should not respond with non-viewable guidance group for a user
  #
  # should respond wiht viewable guidance_group for a user
  #
  # BASIC VIEWS
  # should respond with json
  #
  # should respond with the correct template (index/show.jbuilder)
  #
  # should not respond to post
  #
  # should not respond to put
  #
  # should not respond to delete
  #
  # WHAT IT MEANS TO BE VIEABLE
  # -belongs to the dcc
  # -belongs to any funder
  # -belongs to an organisation, of which the user is a member
  # -TODO: strictly define classes of organisation types, what are proj/institution/reaserch?
  #


end
