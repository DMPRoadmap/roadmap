require 'test_helper'

class ProjectsControllerTest < ActionDispatch::IntegrationTest

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

    get public_export_project_path(locale: I18n.locale, id: @project)
    
    # Should be redirected to the plans controller's export function
    assert_redirected_to "#{export_project_plan_path(@project, @project.plans.first)}", "expected to be redirected to the exported plan"
    follow_redirect!
    
    assert_redirected_to "blah"
    assert_response :success
    assert_equal Mime::PDF, response.content_type
  end

  # ----------------------------------------------------------
  test "should NOT export a non-public plan to unauthorized users" do
    # Set the is_public flag to false and try to access it when not logged in
    @project.visibility = @test_visibility
    @project.save!

    get public_export_project_path(locale: I18n.locale, id: @project)
    
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
  
=begin
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: { dmptemplate_id: @project.dmptemplate_id, locked: @project.locked, note: @project.note, title: @project.title }
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should show project" do
    get :show, id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    put :update, id: @project, project: { dmptemplate_id: @project.dmptemplate_id, locked: @project.locked, note: @project.note, title: @project.title }
    assert_redirected_to project_path(assigns(:project))
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
=end
end
