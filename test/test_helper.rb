ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # Authentication Helpers
  include Devise::TestHelpers
  
  def set_form_authenticity_token
    session[:_csrf_token] = users(:user_one)[:api_token] #SecureRandom.base64(32)
    
puts "Creating auth token #{session[:_csrf_token]}"
  end
  
  def post_with_token(symbol, args = {})
puts "here we are #{symbol}"
    
    args.merge(authenticity_token: set_form_authenticity_token)
    
puts "#{args}"
    
    post(symbol, args)
  end
  
  alias_method :post, :post_with_token
  
  def login_as_admin
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    admin = users(:user_one)
    sign_in :user, admin
  end
  
end
