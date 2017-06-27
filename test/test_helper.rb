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

  # Use the seeds.rb file to seed the test database
  require_relative '../db/seeds.rb'

  # Sometimes TravisCI fails when accessing the LANGUAGES array, so reload it here if necessary
  LANGUAGES = Language.all if LANGUAGES.empty?

  # Get the organisational admin for the Org specified or create one
  # ----------------------------------------------------------------------
  def scaffold_org_admin(org)
    @user = User.create!(email: "admin-#{org.abbreviation.downcase}@example.com", firstname: "Org", surname: "Admin",
                         language: Language.find_by(abbreviation: FastGettext.locale),
                         password: "password123", password_confirmation: "password123",
                         org: org, accept_terms: true, confirmed_at: Time.zone.now,
                         perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs']))
                         #perms: [Perm::GRANT_PERMISSIONS, Perm::MODIFY_TEMPLATES, Perm::MODIFY_GUIDANCE, Perm::CHANGE_ORG_DETAILS])
  end


  # Convert Ruby Class Names into attribute names (e.g. MyClass --> my_class)
  # ----------------------------------------------------------------------
  def class_name_to_attribute_name(name)
    name.gsub(/([a-z]+)([A-Z])/, '\1_\2').gsub('-', '_').downcase
  end

  # Scaffold a new Template with one Phase, one Section, and a Question for
  # each of the possible Question Formats.
  # ----------------------------------------------------------------------
  def scaffold_template
    template = Template.new(title: 'Test template',
                            description: 'My test template',
                            org: Org.first, migrated: false)

    template.phases << Phase.new(title: 'Test phase',
                                 description: 'My test phase',
                                 number: 1, template: template)

    template.phases.first.sections << Section.new(title: 'Test section',
                          description: 'My test section',
                          number: 99, phase: template.phases.first)

    section = template.phases.first.sections.first
    i = 1
    # Add each type of Question to the new section
    QuestionFormat.all.each do |frmt|
      question = Question.new(text: "Test question - #{frmt.title}", number: i,
                              question_format: frmt, section: section)

      if frmt.option_based?
        3.times do |j|
          question.question_options << QuestionOption.new(text: "Option #{j}", number: j, question: question)
        end
      end

      section.questions << question
      i += 1
    end

    template.save!
    assert template.valid?, "unable to create new Template: #{template.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    @template = template.reload
  end

  # Version the template
  # ----------------------------------------------------------------------
  def version_the_template
    put admin_publish_template_path(@template)
    get admin_template_template_path(@template)            # Click on 'edit'
    @template = Template.current(@template.dmptemplate_id) # Edit working copy
    put admin_update_template_path(@template), {template: {title: "#{@template.title} - VERSIONED"}}
  end

  # Scaffold a new Plan based on the scaffolded Template
  # ----------------------------------------------------------------------
  def scaffold_plan
    scaffold_template if @template.nil?

    @plan = Plan.new(template: @template, title: 'Test Plan', grant_number: 'Grant-123',
                        principal_investigator: 'me', principal_investigator_identifier: 'me-1234',
                        description: "this is my plan's informative description",
                        identifier: '1234567890', data_contact: 'me@example.com', visibility: 0,
                        roles: [Role.new(user: User.last, creator: true)])

    assert @plan.valid?, "unable to create new Plan: #{@plan.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    @plan.save!
  end


# FUNCTIONAL/INTEGRATION TEST HELPERS
  # ----------------------------------------------------------------------
  def assert_unauthorized_redirect_to_root_path
    assert_response :redirect
    assert_match "#{root_url}", @response.redirect_url

    follow_redirects

    assert_response :success
    assert_select 'main .page h1', _('Welcome.')
  end

  # ----------------------------------------------------------------------
  def assert_authorized_redirect_to_plans_page
    assert_response :redirect
    assert_match "#{root_url}", @response.redirect_url

    # Sometimes Devise has an intermediary step prior to sending the user to the final destination
    follow_redirects

    assert_response :success
    assert_select 'main .page h1', _('My plans')
  end

  # ----------------------------------------------------------------------
  def follow_redirects
    while @response.status >= 300 && @response.status < 400
      follow_redirect!
    end
  end

# UNIT TEST HELPERS
  # ----------------------------------------------------------------------
  def verify_deep_copy(object, exclusions)
    clazz = Object.const_get(object.class.name)
    assert clazz.respond_to?(:deep_copy), "#{object.class.name} does not have a deep_copy method!"

    copy = clazz.deep_copy(object)
    object.attributes.each do |name, val|
      if exclusions.include?(name)
        assert_not_equal object.send(name), copy.send(name), "expected the deep_copy of #{object.class.name}.#{name} to be unique in the copy"
      else
        assert_equal object.send(name), copy.send(name), "expected the deep_copy of #{object.class.name}.#{name} to match"
      end
    end
  end

  # ----------------------------------------------------------------------
  def verify_has_many_relationship(object, new_association, initial_expected_count)
    # Assumes that the association name matches the pluralized name of the class
    rel = "#{class_name_to_attribute_name(new_association.class.name).pluralize}"

    assert_equal initial_expected_count, object.send(rel).count, "was expecting #{object.class.name} to initially have #{initial_expected_count} #{rel}"

    # Add another association for the object
    object.send(rel) << new_association
    object.save!
    assert_equal (initial_expected_count + 1), object.send(rel).count, "was expecting #{object.class.name} to have #{initial_expected_count + 1} #{rel} after adding a new one - #{new_association.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

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
