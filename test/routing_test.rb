require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  
  include Devise::Test::IntegrationHelpers
  
  setup do
    scaffold_plan
  end

  # Routing for the home page
  # ------------------------------------------------------------------- 
  test 'GET / should resolve to HomeController#index' do
    assert_routing '/', controller: 'home', action: 'index'
  end

  # Routing for Static Pages
  # ------------------------------------------------------------------- 
  test 'GET /about_us should resolve to StaticPagesController#about_us' do
    target = {controller: "static_pages", action: "about_us"}
    assert_routing about_us_path, target
  end

  test 'GET /help should resolve to StaticPagesController#help' do
    target = {controller: "static_pages", action: "help"}
    assert_routing help_path, target
  end
  test 'GET /roadmap should resolve to StaticPagesController#roadmap' do
    target = {controller: "static_pages", action: "roadmap"}
    assert_routing roadmap_path, target
  end
  test 'GET /terms should resolve to StaticPagesController#terms' do
    target = {controller: "static_pages", action: "termsuse"}
    assert_routing terms_path, target
  end
  test 'GET /public_plans should resolve to PublicPagesController#plan_index' do
    target = {controller: "public_pages", action: "plan_index"}
    assert_routing public_plans_path, target
  end
  test 'GET /public_export should resolve to PublicPagesController#plan_export' do
    plan = Plan.first
    target = {controller: "public_pages", action: "plan_export", id: plan.id.to_s}
    
    assert_routing plan_export_path(id: plan), target
  end

  # OAuth - Based on providers identified in the en-UK locale file
  # ------------------------------------------------------------------- 
  test "POST /auth/[:provider]/callback should resolve to OmniauthCallbackController#[:provider]" do
    IdentifierScheme.where(active: true).all.each do |scheme|
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
  
end