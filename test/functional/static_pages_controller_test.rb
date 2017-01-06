class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @project = Project.first
    
    @test_visibility = Visibility.find_by(name: 'test')
    @public_visibility = Visibility.find_by(name: 'public')
  end

  # ----------------------------------------------------------
  test "should export the publicly available plan" do
    @project.visibility = @public_visibility
    @project.save!

#    get public_export_path(locale: I18n.locale, id: @project)
    
    # Should be redirected to the plans controller's export function
#    assert_redirected_to "#{export_project_plan_path(@project, @project.plans.first)}", "expected to be redirected to the exported plan"
#    follow_redirect!
    
#    assert_redirected_to "blah"
#    assert_response :success
#    assert_equal Mime::PDF, response.content_type
  end

  # ----------------------------------------------------------
  test "should NOT export a non-public plan to unauthorized users" do
    # Set the is_public flag to false and try to access it when not logged in
    @project.visibility = @test_visibility
    @project.save!

    get public_export_path(locale: I18n.locale, id: @project)
    
    assert_redirected_to "#{root_path}?locale=#{I18n.locale}", "expected to be redirected to the home page!"
    assert_equal I18n.t('helpers.settings.plans.errors.no_access_account'), flash[:notice], "Expected an unauthorized message when trying to export a plan (via the public_export route) when the plan is not actually public"
    
    # Set the is_public flag to false and assign ownership to a different user and then try to access it as a non-owner
    @project.assign_creator(User.last)
    @project.save!
    
    sign_in User.first
    
    get public_export_project_path(locale: I18n.locale, id: @project)
    
    assert_redirected_to "#{root_path}?locale=#{I18n.locale}", "expected to be redirected to the home page!"
    assert_equal I18n.t('helpers.settings.plans.errors.no_access_account'), flash[:notice], "Expected an unauthorized message when trying to export a plan (via the public_export route) when the plan is not actually public"
  end
end