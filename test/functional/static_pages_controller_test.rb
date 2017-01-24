class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    @public_project = Project.create!({title: 'Public Test Project', 
                                       dmptemplate: Dmptemplate.first, 
                                       organisation: Organisation.first,
                                       visibility: :publicly_visible})
  end

  # ----------------------------------------------------------
  test "should only return plans with public visibility" do
    get public_plans_path(locale: I18n.locale)
    
    assert_response :success
    assert_not_nil assigns(:projects)
    
    all_public = true
    
    assigns(:projects).each do |project|
      all_public = false unless project.publicly_visible?
    end
    
    assert all_public, "expected all of the plans to have public visibility!"
  end

  # ----------------------------------------------------------
  test "should export the publicly available plan" do
    
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
    @public_project.visibility = :privately_visible
    @public_project.save!

    get public_export_path(locale: I18n.locale, id: @public_project)
    
    assert_redirected_to "#{public_plans_path}", "expected to be redirected to the home page!"
    assert_equal I18n.t('helpers.settings.plans.errors.no_access_account'), flash[:notice], "Expected an unauthorized message when trying to export a plan (via the public_export route) when the plan is not actually public"
    
    # Set the is_public flag to false and assign ownership to a different user and then try to access it as a non-owner
    @public_project.assign_creator(User.last)
    @public_project.save!
    
    sign_in User.first
    
    get public_export_path(locale: I18n.locale, id: @public_project)
    
    assert_redirected_to "#{public_plans_path}", "expected to be redirected to the home page!"
    assert_equal I18n.t('helpers.settings.plans.errors.no_access_account'), flash[:notice], "Expected an unauthorized message when trying to export a plan (via the public_export route) when the plan is not actually public"
  end
end