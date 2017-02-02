require 'test_helper'

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:cc_super)
    
    stub_blog_calls
  end
  
  # In order to test methods on the application controller, we must call routes
  # on controllers that extend the ApplicationController class.
  
  # ----------------------------------------------------------------
  test "make sure unauthorized users are redirected to the root path" do
    proj = Project.first
    get project_path(I18n.locale, proj)
    
    assert_redirected_to "#{root_path}?locale=#{I18n.locale}"
  end

  # ----------------------------------------------------------------
  test "we can change the locale by changing the URL" do
    proj = Project.first
    
    if I18n.available_locales.count > 1
      # Verify that passing a locale in the URL will set the locale
      other = I18n.available_locales.last
      
      get project_path(other, proj)
      assert_redirected_to "#{root_path}?locale=#{I18n.locale}", "Expected the changed locale to appear in the query string"
      assert_equal other, I18n.locale, "Expected the locale to have been set when passing it in URL"
    end
  end
  
  # ----------------------------------------------------------------
  test "a user's language specification is used if no locale is passed in the URL" do
    if I18n.available_locales.count > 1
      @user.language = Language.find_by(abbreviation: I18n.available_locales.last)
      @user.save!
      
      sign_in @user
      
      get root_path
      assert_equal @user.language.abbreviation.to_s, I18n.locale.to_s, "Expected the locale to have been set to the user's chosen language"
      assert "#{projects_path}".starts_with?("/#{@user.language.abbreviation}/"), "Expected the system to use the user's language specification"
    end
  end
  
  # ----------------------------------------------------------------
  test "a user's organisation language specification is used if no locale is passed in the URL and the user has no language setting" do
    if I18n.available_locales.count > 1
      @user.language = nil
      @user.organisation[:language_id] = Language.find_by(abbreviation: I18n.available_locales.last).id
      @user.save!
      
      sign_in @user
      
      get root_path
      org_lang = Language.find(@user.organisation[:language_id]).abbreviation 
      assert_equal org_lang.to_s, I18n.locale.to_s, "Expected the locale to have been set to the organisation's chosen language"
      assert "#{projects_path}".starts_with?("/#{org_lang}/"), "Expected the system to use the organisation's language specification"
    end
  end

  # ----------------------------------------------------------------
  test "the last visited url is stored in the session" do
    get root_path
    assert_equal root_path, session[:previous_url]
    
    sign_in @user
    get projects_path
    assert_equal projects_path, session[:previous_url]
  end
  
end
