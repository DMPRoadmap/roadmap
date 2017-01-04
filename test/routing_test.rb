require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest

  # Routing for the home page
  # ------------------------------------------------------------------- 
  test 'GET / should resolve to HomeController#index' do
    assert_routing '/', controller: 'home', action: 'index'
    assert_routing "/#{I18n.locale}", controller: 'home', action: 'index', 
                    locale: "#{I18n.locale}"
  end

  # Routing for Static Pages
  # ------------------------------------------------------------------- 
  test 'GET /about_us should resolve to StaticPagesController#about_us' do
    target = {controller: "static_pages", action: "about_us", locale: "#{I18n.locale}"}
    assert_routing about_us_path(locale: I18n.locale), target
  end

  test 'GET /help should resolve to StaticPagesController#help' do
    target = {controller: "static_pages", action: "help", locale: "#{I18n.locale}"}
    assert_routing help_path(locale: I18n.locale), target
  end
  test 'GET /roadmap should resolve to StaticPagesController#roadmap' do
    target = {controller: "static_pages", action: "roadmap", locale: "#{I18n.locale}"}
    assert_routing roadmap_path(locale: I18n.locale), target
  end
  test 'GET /terms should resolve to StaticPagesController#terms' do
    target = {controller: "static_pages", action: "termsuse", locale: "#{I18n.locale}"}
    assert_routing terms_path(locale: I18n.locale), target
  end
  
  # Routing for Public DMPs 
  # ------------------------------------------------------------------- 
  test 'GET /public_plans should resolve to ProjectsController#public_plans' do
    target = {controller: "projects", action: "public_plans", locale: "#{I18n.locale}"}
    assert_routing public_plans_path(locale: I18n.locale), target
  end
  test 'GET /projects/[:project_id]/plans/[:id]/public_export should resolve to PlansController#public_export' do
    project = Project.includes(:plans).where.not(plans: {id: nil}).first
    target = {controller: "projects", action: "public_export", locale: "#{I18n.locale}", id: project.id.to_s}
    
    assert_routing public_export_project_path(locale: I18n.locale, id: project), target
  end

  # OAuth - Based on providers identified in the en-UK locale file
  # ------------------------------------------------------------------- 
  test "GET /users/auth/[:provider] should resolve to OmniauthCallbackController#passthru" do
    target = {controller: "users/omniauth_callbacks", action: "passthru"}

    IdentifierScheme.all.each do |scheme|
      assert_routing "/users/auth/#{scheme.name.downcase}", target
    end
  end
  
  test "POST /auth/[:provider]/callback should resolve to OmniauthCallbackController#[:provider]" do
    IdentifierScheme.all.each do |scheme|
      target = {controller: "users/omniauth_callbacks", action: "#{scheme.name.downcase}"}
      assert_routing "/users/auth/#{scheme.name.downcase}/callback", target
    end
  end
  
  
  # Routing for Users (Some resolve to UsersController and others to Devise's 
  # RegistrationController)
  # ------------------------------------------------------------------- 
=begin
  test "GET /users should resolve to UsersController#index" do
    assert_routing "/users", controller: 'users', action: 'index'
  end
  
  test "GET /users/new should resolve to UsersController#new" do
    assert_routing "/users/new", controller: 'users', action: 'new'
  end
  
  test "GET /users/1 should resolve to UsersController#show for user 1" do
    assert_routing "/users/1", controller: 'users', action: 'show', id: '1'
  end
  
  test "GET /users/edit should resolve to UsersController#edit" do
    assert_routing "/users/1/edit", controller: 'users', action: 'edit', id: '1'
  end
  
  test "POST /users should resolve to Devise's RegistrationsController#create" do
    assert_routing({path: "/users", method: 'post'}, 
                   {controller: 'registrations', action: 'create'})
  end
  
  test "PUT /users/1 should resolve to Devise's RegistrationsController#update" do
    assert_routing({path: "/users", method: 'put'}, 
                   {controller: 'registrations', action: 'update'})
  end
  
  test "PATCH /users/1 should resolve to Devise's RegistrationsController#update" do
    assert_routing({path: "/users", method: 'patch'}, 
                   {controller: 'registrations', action: 'update'})
  end
  
  test "DELETE /users/1 should resolve to Devise's RegistrationsController#update" do
    assert_routing({path: "/users", method: 'delete'}, 
                   {controller: 'registrations', action: 'destroy'})
  end
=end
  
  private
    def test_localized_and_unlocalized(path, controller, action)
      # Check that the path without localization is working
      assert_routing "#{path}", {controller: "#{controller}", action: "#{action}"}
      
      # Check that the path with localization is working
      assert_routing "/#{I18n.locale}#{path}", {controller: "#{controller}", 
                      action: "#{action}", locale: "#{I18n.locale}"}
    end
end