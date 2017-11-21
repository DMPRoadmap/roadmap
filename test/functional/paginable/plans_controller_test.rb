require 'test_helper'

class PlansControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.find_by(email: 'super_admin@example.com')
    #@plans_total = Kaminari.config.default_per_page
    #(1..@plans_total+1).each do
    #  Plan.create(title: 'Test Plan', template: @user.org.templates.first, grant_number: 'Plan12345',
    #                    identifier: '000912', description: 'This is a test plan',
    #                    principal_investigator: 'Foo Bar', principal_investigator_identifier: 'ABC',
    #                    data_contact: 'foo.bar@example.com', visibility: :privately_visible).assign_creator(@user.id)
    #end
  end
  test 'privately_visible action renders layout view for page param ALL' do
    sign_in @user
    get privately_visible_paginable_plans_path('ALL')
    assert_response :success
    # Checks the existence of a link with href equals to privately_visible_paginable_plans_path(1)
    # assert_select('.paginable-layout .pull-left a[href=?]', privately_visible_paginable_plans_path(1))
    # Checks the existence of a link (e.g. View Less) with data-remote attribute as true (for AJAX requests)
    # assert_select('.paginable-layout .pull-left a[data-remote=?]', 'true')
    # Checks that does not exist any nav with class pagination in the view rendered (e.g. no pagination)
    # assert_select('nav.pagination', { count: 0 })
  end
  test 'privately_visible action renders layout view for page param 1' do
    sign_in @user
    get privately_visible_paginable_plans_path(1)
    assert_response :success
    #assert_select('.paginable-layout .pull-left a[href=?]', privately_visible_paginable_plans_path('ALL'))
    #assert_select('.paginable-layout .pull-left a[data-remote=?]', 'true')
    #assert_select('nav.pagination', { count: 1 })
    #assert_select('nav.pagination .page.current', { count: 1, text: '1' })
  end 
end

# assert_select reference at http://www.rubydoc.info/github/rails/rails-dom-testing/Rails/Dom/Testing/Assertions/SelectorAssertions