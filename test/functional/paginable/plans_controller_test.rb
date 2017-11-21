require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  # setup do
  #   @user = User.find_by(email: 'super_admin@example.com')
  #   sign_in @user
  #   @plans_total = Kaminari.config.default_per_page
  #   (1..@plans_total+1).each do
  #     Plan.create(title: 'Test Plan', template: @user.org.templates.first, grant_number: 'Plan12345',
  #                       identifier: '000912', description: 'This is a test plan',
  #                       principal_investigator: 'Foo Bar', principal_investigator_identifier: 'ABC',
  #                       data_contact: 'foo.bar@example.com', visibility: :privately_visible).assign_creator(@user.id)
  #   end
  # end
  # test 'privately_visible action renders layout view for page param ALL' do
  #   get privately_visible_paginable_plans_path('ALL')
  #   assert_response :success
  #   assert_select('.paginable-layout .pull-left a', 'View less')
  #   assert_select('.paginable-layout .pull-left a[data-remote=?]', 'true')
  #   css_select('.paginable-layout .pull-left a').class
  #   assert(css_select('nav.pagination').length == 0) 
  # end
  # test 'privately_visible action renders layout view for page param 1' do
  #   get privately_visible_paginable_plans_path(1)
  #   assert_response :success
  #   assert_select('.paginable-layout .pull-left a', 'View all')
  #   assert_select('.paginable-layout .pull-left a[data-remote=?]', 'true')
  #   assert(css_select('nav.pagination').length > 0)
  # end
  # teardown do
  #   sign_out @user
  # end 
end