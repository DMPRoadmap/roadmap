ENV["RAILS_ENV"] = "test"

# Startup the simple coverage gem so that our test results are captured
require 'simplecov'
SimpleCov.start 'rails'

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'
require 'active_support/inflector' # For pluralization utility

class ActiveSupport::TestCase
  include GlobalHelpers
  
  # Suppress noisy ActiveRecord logs because fixtures load for each test
  ActiveRecord::Base.logger.level = Logger::INFO
  
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Use the db/seed.rb file to populate the test DB
  require_relative '../db/seeds.rb'

  # Add more helper methods to be used by all tests here...
  
  # Convert Ruby Class Names into attribute names (e.g. MyClass --> my_class)
  # ----------------------------------------------------------------------
  def class_name_to_attribute_name(name)
    name.gsub(/([a-z]+)([A-Z])/, '\1_\2').gsub('-', '_').downcase
  end
  
# FUNCTIONAL/INTEGRATION TEST HELPERS
  # ----------------------------------------------------------------------
  def assert_unauthorized_redirect_to_root_path
    assert_response :redirect
    assert_match "#{root_url}", @response.redirect_url
    
    follow_redirect!
    assert_response :success
    assert_select '.welcome-message h2', I18n.t('welcome_title')
  end
  
  # ----------------------------------------------------------------------
  def assert_authorized_redirect_to_plans_page
    assert_response :redirect
    assert_match "#{root_url}", @response.redirect_url
    
    # Sometimes Devise has an intermediary step prior to sending the user to the final destination
    while @response.status >= 300 && @response.status < 400
      follow_redirect!
    end
    
    assert_response :success
    assert_select '.main_page_content h1', I18n.t('helpers.project.projects_title')
  end
  
  
# UNIT TEST HELPERS
  # ----------------------------------------------------------------------
  def verify_has_many_relationship(object, new_association, initial_expected_count)
    # Assumes that the association name matches the pluralized name of the class
    rel = "#{class_name_to_attribute_name(new_association.class.name).pluralize}"
    
    assert_equal initial_expected_count, object.send(rel).count, "was expecting #{object.class.name} to initially have #{initial_expected_count} #{rel}"
    
    # Add another association for the object
    object.send(rel) << new_association
    object.save!
    assert_equal (initial_expected_count + 1), object.send(rel).count, "was expecting #{object.class.name} to have #{initial_expected_count + 1} #{rel} after adding a new one"
    
    # Remove the newly added association
    object.send(rel).delete(new_association)
    object.save!
    assert_equal initial_expected_count, object.send(rel).count, "was expecting #{object.class.name} to have #{initial_expected_count} #{rel} after removing the new one we added"
  end
  
  # ----------------------------------------------------------------------
  def verify_belongs_to_relationship(child, parent)
    # Assumes that the association name matches the lower case name of the class
    prnt = "#{class_name_to_attribute_name(parent.class.name)}"
    chld = "#{class_name_to_attribute_name(child.class.name)}"
    
    child.send("#{prnt}=", parent)
    child.save!
    assert_equal parent, child.send(prnt), "was expecting #{chld} to have a #{prnt}.id == #{parent.id}"
    
    # Search the parent for the child
    parent.reload
    assert_includes parent.send("#{chld.pluralize}"), child, "was expecting the #{prnt}.#{chld.pluralize} to contain the #{chld}"
  end
  
# STUBS FOR CALLS To EXTERNAL SITES
  # ----------------------------------------------------------------------
  def stub_blog_calls
    blog_feed = "<?xml version=\"1.0\" encoding=\"utf-8\" ?><rss version=\"2.0\" " +
                      "xml:base=\"http://www.example.com/stubbed/blog\" " +
                      "xmlns:dc=\"http://purl.org/dc/elements/1.1\">" +
                "<channel>" +
                  "<title>Testing</title>" +
                  "<link>http://www.example.com/stubbed/blog/feed</link>" +
                  "<item>" +
                    "<title>Stub blog post</title>" +
                    "<link>http://www.example.com/stubbed/blog/articles/1</link>" +
                    "<description>This is a stuubed blog post</description>" +
                    "<category domain=\"http://www.example.com/stubbed/blog\">Test</category>" +
                    "<pubDate>Thu, 03 Nov 2016 12:38:17 +0000</pubDate>" +
                    "<dc:creator />" +
                    "<guid isPermaLink=\"false\">1 at http://www.example.com/stubbed/blog</guid>" +
                  "</item>" +
                "</channel>"
  
    stub_request(:get, "http://www.dcc.ac.uk/news/dmponline-0/feed").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Faraday v0.9.2'}).
      to_return(:status => 200, :body => blog_feed, :headers => {})
  end
end
