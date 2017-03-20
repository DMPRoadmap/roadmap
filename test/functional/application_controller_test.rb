require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.first
    
    stub_blog_calls
    
    scaffold_plan
  end
  
  # In order to test methods on the application controller, we must call routes
  # on controllers that extend the ApplicationController class.
  
  # ----------------------------------------------------------------
  test "make sure unauthorized users are redirected to the root path" do
    plan = Plan.first
    get plan_path(plan)
    
    assert_redirected_to "#{root_path}"
  end

  # ----------------------------------------------------------------
  test "a user's language specification is set in the session" do
    if LANGUAGES.count > 1
      @user.language = LANGUAGES.last
      @user.save!
      
      sign_in @user
      
      get root_path
      
      assert_equal @user.language, session[:locale], "Expected the locale to have been set to the user's chosen language"
    end
  end
  
  # ----------------------------------------------------------------
  test "a user's org language specification is used if no locale is passed in the URL and the user has no language setting" do
    if LANGUAGES.count > 1
      @user.language = nil
      @user.org[:language_id] = LANGUAGES.last.id
      @user.save!
      
      sign_in @user
      
      get root_path
      org_lang = Language.find(@user.org[:language_id]) 
      assert_equal org_lang, session[:locale], "Expected the locale to have been set to the org's chosen language"
    end
  end

  # ----------------------------------------------------------------
  test "the last visited url is stored in the session" do
    get root_path
    assert_equal root_path, session[:previous_url]
    
    sign_in @user
    get plans_path
    assert_equal plans_path, session[:previous_url]
  end
  
end
