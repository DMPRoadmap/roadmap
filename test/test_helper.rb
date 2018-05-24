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

  # Default attributes for model initialization
  def org_seed  
    { name: 'Test Institution',
      abbreviation: 'TST',
      org_type: Org.org_type_values_for(:institution).min,
      target_url: 'http://test-funder.org',
      language: LANGUAGES.first,
      contact_email: 'help.desk@test-funder.org',
      contact_name: 'Help Desk',
      links: {"org":[{"link":"http://dmproadmap.org","text":"DMPRoadmap"}]},
    }
  end
  def user_seed
    {
      email: 'test-user@testing-roadmap.org', 
      firstname: 'Test', 
      surname: 'User',
      language: Language.find_by(abbreviation: FastGettext.locale),
      password: "password123", 
      password_confirmation: "password123",
      accept_terms: true, 
      confirmed_at: Time.zone.now, 
    }
  end

  def template_seed 
    {
      title: 'Test template', 
      description: 'this is a test template',
      org: Org.first, 
    }
  end
  def phase_seed
    {
      title: 'Test phase',
      description: 'This is a phase used for testing',
      number: 1,
      modifiable: true,
    }
  end
  def section_seed
    {
      title: 'Test section',
      description: 'This is a section used for testing',
      number: 1,
      modifiable: true,
    }
  end
  def question_format_seed 
    {
      title: 'Text area',
      option_based: false,
      formattype: QuestionFormat.formattypes[:text_area]
    }
  end
  def question_seed
    {
      text: 'how is our test coverage?',
      default_value: 'Not as good as it could be.',
      number: 1,
      option_comment_display: true,
      modifiable: true,
    }
  end
  def annotation_seed
    {
      text: 'This is some test guidance for a customization',
      type: Annotation.types[:guidance]
    }
  end
  def question_option_seed
    {
      text: 'Option A',
      number: 1,
      is_default: true,
    }
  end
  def plan_seed 
    {
      title: 'Test plan',
      funder_name: 'Organisation with a lot of funds',
      grant_number: 'Grant123',
      identifier: '123456789',
      description: 'This is the project abstract.',
      visibility: Plan.visibilities[:privately_visible],
      principal_investigator: 'Jane Doe',
      principal_investigator_identifier: 'ORCID123',
      principal_investigator_email: 'jane.doe@pi.roadmap.org',
      principal_investigator_phone: '1234',
      data_contact: 'John Doe',
      data_contact_email: 'john.doe@pi.roadmap.org',
      data_contact_phone: '5678',
    }
  end
  def theme_seed
    {
      title: 'Test theme',
      description: 'This theme is used for testing',
      locale: Language.find_by(abbreviation: FastGettext.locale),
    }
  end
  def guidance_group_seed
    {
      name: 'Test guidance group',
      optional_subset: false,
      published: true,
    }
  end
  def guidance_seed
    {
      text: 'This is thematic test guidance.',
      published: true,
    }
  end
  
  def validate_and_create_obj(obj)
    obj.validate
    if obj.errors.present?
      # Unable to save the object, so output an error rather than burying it
      puts "Unable to save #{obj.class.name} because: #{obj.errors.collect{ |e,m| "#{e}: #{m}" }.join(', ')}"
    else
      obj.save!
    end
    assert obj.valid?
    obj
  end
  
  # Org initializers
  def init_institution(**props)
    validate_and_create_obj(Org.new(org_seed.merge(props)))
  end
  def init_funder(**props)
    hash = { name: 'Test Funder', abbreviation: 'TSTFNDR', org_type: Org.org_type_values_for(:funder).min }
    validate_and_create_obj(Org.new(org_seed.merge(hash.merge(props))))
  end
  def init_organisation(**props)
    hash = { name: 'Test Organisation', abbreviation: 'TSTORG', org_type: Org.org_type_values_for(:organisation).min }
    validate_and_create_obj(Org.new(org_seed.merge(hash.merge(props))))
  end
  def init_funder_organisation(**props)
    hash = { name: 'Test Funder/Organisation', abbreviation: 'TSTFNDRORG', org_type: Org.org_type_values_for(:funder, :organisation).min }
    validate_and_create_obj(Org.new(org_seed.merge(hash.merge(props))))
  end

  # User initializers
  def init_researcher(org, **props)
    validate_and_create_obj(User.new(user_seed.merge({ 
      org: org, 
      surname: 'Researcher',
      email: 'researcher@testing-roadmap.org',
     }.merge(props))))
  end
  def init_org_admin(org, **props)
    perms = Perm.where.not(name: ['admin', 'add_organisations', 
                                  'change_org_affiliation', 'grant_api_to_orgs', 
                                  'change_org_details'])
    validate_and_create_obj(User.new(user_seed.merge({ 
      org: org, 
      surname: 'OrgAdmin', 
      email: 'org.admin@testing-roadmap.org',
      perms: perms,
     }.merge(props))))
  end
  def init_super_admin(org, **props)
    perms = Perm.all
    validate_and_create_obj(User.new(user_seed.merge({ 
      org: org, 
      surname: 'SuperAdmin', 
      email: 'super.admin@testing-roadmap.org',
      perms: perms 
    }.merge(props))))
  end
  
  # Template initializers
  def init_template(org, **props)
    if org.is_a? Org
      validate_and_create_obj(Template.new(template_seed.merge({ org: org }.merge(props))))
    else
      puts "You must supply an Org when creating a template! Got the following instead: #{org.inspect}"
      nil
    end
  end
  def init_phase(template, **props)
    if template.is_a? Template
      validate_and_create_obj(Phase.new(phase_seed.merge({ template: template }.merge(props))))
    else
      puts "You must supply a Template when creating a phase! Got the following instead: #{template.inspect}"
      nil
    end
  end
  def init_section(phase, **props)
    if phase.is_a? Phase
      validate_and_create_obj(Section.new(section_seed.merge({ phase: phase }.merge(props))))
    else
      puts "You must supply a Phase when creating a section! Got the following instead: #{phase.inspect}"
      nil
    end
  end
  def init_question_format(**props)
    validate_and_create_obj(QuestionFormat.new(question_format_seed.merge(props)))
  end
  def init_question(section, **props)
    if section.is_a? Section
# TODO call init_question_format instead once the seeds.rb has been removed
      props[:question_format] = QuestionFormat.first unless props[:question_format].present?
      validate_and_create_obj(Question.new(question_seed.merge({ section: section }.merge(props))))
    else
      puts "You must supply a Section when creating a question! Got the following instead: #{section.inspect}"
      nil
    end
  end
  def init_annotation(org, question, **props)
    if org.is_a?(Org) && question.is_a?(Question)
      validate_and_create_obj(Annotation.new(annotation_seed.merge({ org: org, question: question }.merge(props))))
    else
      puts "You must supply an Org and Question when creating an annotation! Got the following instead: ORG - #{org.inspect}, QUESTION - #{question.inspect}"
      nil
    end
  end
  def init_question_option(question, **props)
    if question.is_a?(Question)
      validate_and_create_obj(QuestionOption.new(question_option_seed.merge({ question: question }.merge(props))))
    else
      puts "You must supply a Question when creating a question option! Got the following instead: QUESTION - #{question.inspect}"
      nil
    end
  end
  def init_theme(**props)
    validate_and_create_obj(Theme.new(theme_seed.merge(props)))
  end
  def init_guidance_group(org, **props)
    if org.is_a? Org
      validate_and_create_obj(GuidanceGroup.new(guidance_group_seed.merge({ org: org }.merge(props))))
    else
      puts "You must supply an Org when creating a GuidanceGroup! Got the following instead: ORG: #{org.inspect}"
    end
  end
  def init_guidance(guidance_group, **props)
    if guidance_group.is_a?(GuidanceGroup)
      validate_and_create_obj(Guidance.new(guidance_seed.merge({ guidance_group: guidance_group }.merge(props))))
    else
      puts "You must supply a GuidanceGroup when creating a Guidance! Got the following instead: GUIDANCE_GROUP: #{guidance_group.inspect}"
    end
  end
  def init_plan(template, **props)
    if template.is_a? Template
      validate_and_create_obj(Plan.new(plan_seed.merge({ template: template }.merge(props))))
    else
      puts "You must supply a Template when creating a plan! Got the following instead: #{template.inspect}"
      nil
    end
  end
  
  # equality helpers for complex objects
  def assert_annotations_equal(annotation1, annotation2)
    assert_equal annotation1.text, annotation2.text, 'expected the annotations to have the same text'
    assert_equal annotation1.type, annotation2.type, 'expected the annotations to be of the same type'
  end
  def assert_question_options_equal(option1, option2)
    assert_equal option1.text, option2.text, 'expecetd the question options to have the same text'
    assert_equal option1.number, option2.number, 'expecetd the question options to have the same number'
    assert_equal option1.is_default, option2.is_default, 'expecetd the question options to have the same default flag value'
  end
  def assert_questions_equal(question1, question2)
    assert_equal question1.number, question2.number, 'expected the question numbers to match'
    assert_equal question1.text, question2.text, 'expected the question text to match'
    assert_equal question1.question_format, question2.question_format, 'expected the question formats to match'
    assert_equal question1.option_comment_display, question2.option_comment_display, 'expected the question optional comment display flags to match'
    assert_equal question1.annotations.length, question2.annotations.length, 'expected the questions to have the same number of annotations'
    assert_equal question1.question_options.length, question2.question_options.length, 'expected the questions to have the same number of options'
    question1.annotations.each_with_index do |annotation, idx|
      assert_annotations_equal(annotation, question2.annotations[idx])
    end
    question1.question_options.each_with_index do |option, idx|
      assert_question_options_equal(option, question2.question_options[idx])
    end
  end
  def assert_sections_equal(section1, section2)
    assert_equal section1.number, section2.number, 'expected the section numbers to match'
    assert_equal section1.title, section2.title, 'expected the section titles to match'
    assert_equal section1.description, section2.description, 'expected the section descriptions to match'
    assert_equal section1.questions.length, section2.questions.length, 'expected the sections to have the same number of questions'
    section1.questions.each_with_index do |question, idx|
      assert_questions_equal(question, section2.questions[idx])
    end
  end
  def assert_phases_equal(phase1, phase2)
    assert_equal phase1.number, phase2.number, 'expected the phase numbers to match'
    assert_equal phase1.title, phase2.title, 'expected the phase titles to match'
    assert_equal phase1.description, phase2.description, 'expected the phase descriptions to match'
    assert_equal phase1.sections.length, phase2.sections.length, 'expected the phase to have the same number of sections'
    phase1.sections.each_with_index do |section, idx|
      assert_sections_equal(section, phase2.sections[idx])
    end
  end


  # Get the organisational admin for the Org specified or create one
  # ----------------------------------------------------------------------
  def scaffold_org_admin(org)
    @user = User.create!(email: "admin-#{org.abbreviation.downcase}@example.com", firstname: "Org", surname: "Admin",
                         language: Language.find_by(abbreviation: FastGettext.locale),
                         password: "password123", password_confirmation: "password123",
                         org: org, accept_terms: true, confirmed_at: Time.zone.now,
                         perms: Perm.where.not(name: ['admin', 'add_organisations', 'change_org_affiliation', 'grant_api_to_orgs', 'change_org_details']))
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
                            links: {"funder":[],"sample_plan":[]},
                            org: Org.first, archived: false, family_id: "0000009999")

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
    @template = @template.generate_version!
  end

  # Scaffold a new Plan based on the scaffolded Template
  # ----------------------------------------------------------------------
  def scaffold_plan
    scaffold_template if @template.nil?

    @plan = Plan.new(template: @template, title: 'Test Plan', grant_number: 'Grant-123',
                        principal_investigator: 'me', principal_investigator_identifier: 'me-1234',
                        description: "this is my plan's informative description",
                        identifier: '1234567890', data_contact: 'me@example.com', visibility: :privately_visible,
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
    assert_select 'main h1', _('Welcome.')
  end

  # ----------------------------------------------------------------------
  def assert_authorized_redirect_to_plans_page
    assert_response :redirect
    assert_match "#{root_url}", @response.redirect_url

    # Sometimes Devise has an intermediary step prior to sending the user to the final destination
    follow_redirects

    assert_response :success
    assert_select 'main h1', _('My Dashboard')
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
        unless object.send(name).nil? || copy.send(name)
          assert_equal object.send(name), copy.send(name), "expected the deep_copy of #{object.class.name}.#{name} to match"
        end
      end
    end
  end

  def assert_deep_copy(original, copy, **options)
    if original.class == copy.class
        relations = options.fetch(:relations, []).map(&:to_sym)
        assert(original.object_id != copy.object_id)
        assert_nil(copy.id, "id should be nil for #{copy.class}") if copy.respond_to?(:id)
        assert_nil(copy.created_at, "created_at should be nil for #{copy.class}") if copy.respond_to?(:created_at)
        assert_nil(copy.updated_at, "updated_at should be nil for #{copy.class}") if copy.respond_to?(:updated_at)
        relations.each do |relation|
          if copy.respond_to?(relation)
            relation_obj = copy.send(relation)
            if relation_obj.respond_to?(:each)
              relation_obj.each do |obj|
                assert_nil(obj.id, "id should be nil for the relation object from #{obj.class}") if copy.respond_to?(:id)
              end 
            end
          end
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
