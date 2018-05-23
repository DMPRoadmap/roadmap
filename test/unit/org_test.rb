require 'test_helper'

class OrgTest < ActiveSupport::TestCase
  setup do
    @org = Org.create!(name: 'Testing', abbreviation: 'TST', links: {"org":[]})
    
    @language = Language.find_by(abbreviation: I18n.default_locale)
  end
  
  # ---------- required fields are required ------------
  test "required fields should be required" do
    org = Org.new
    assert_not(org.valid?)
    
    org.name = 'ABCD'
    org.links = {"org":[]}
    assert(org.valid?)
  end
  
  # ---------- short_name ----------
  test "short_name should return the abbreviation if it exists" do
    assert_equal(@org.abbreviation, @org.short_name)
  end

  test "short_name should return the name if no abbreviation exists" do
    @org.abbreviation = nil
    assert_equal(@org.name, @org.short_name)
  end

  # ---------------------------------------------------
  test "to_s returns the name" do
    assert_equal @org.name, @org.to_s
  end

  # ---------------------------------------------------
  test "type returns the correct value" do
    @org.institution = true
    assert_equal "Institution", @org.org_type_to_s
    
    @org.institution = false
    @org.funder = true
    assert_equal "Funder", @org.org_type_to_s
    
    @org.funder = false
    @org.organisation = true
    assert_equal "Organisation", @org.org_type_to_s
    
    @org.organisation = false
    @org.research_institute = true
    assert_equal "Research Institute", @org.org_type_to_s
    
    @org.research_institute = false
    @org.project = true
    assert_equal "Project", @org.org_type_to_s
    
    @org.project = false
    @org.school = true
    assert_equal "School", @org.org_type_to_s
    
    @org.school = false
    assert_equal "None", @org.org_type_to_s
    
    @org.funder = true
    @org.organisation = true
    assert_equal "Funder, Organisation", @org.org_type_to_s
  end
  
  # ---------------------------------------------------
  test "should resize logo to a height of 100" do
    ['logo.jpg', # this one is at 160x160
     'logo_300x300.jpg', 
     'logo_100x100.jpg'].each do |file|
       
       path = File.expand_path("../../assets/#{file}", __FILE__)
       @org.logo = Dragonfly.app.fetch_file("#{path}")
       
       assert @org.valid?, "expected the logo to have been attached to the org"
       assert_equal 100, @org.logo.height, "expected the logo to have been resized properly"
    end
  end
  
  # ---------------------------------------------------
  test "should remove all associated User's api tokens if no TokenPermissionTypes are present" do
    @org.token_permission_types << TokenPermissionType.first
    usr = User.new(email: 'tester@testing.org', password: 'testing123')
    usr.keep_or_generate_token!
    
    original = usr.api_token
    @org.users << usr
    
    # Make sure that the user's API token was saved
    @org.save!
    usr = @org.reload.users.find_by(email: 'tester@testing.org')
    assert_equal original, usr.api_token
    
    # TODO: Determine if this should just be removed or if it should still be removing these
    # Make sure that the user's API token is cleared out when all API permissions
    # for the org have been removed
    #@org.token_permission_types.clear
    #@org.save!
    #usr = @org.reload.users.find_by(email: 'tester@testing.org')
    #assert_equal nil, usr.api_token
  end
  
  # ---------------------------------------------------
  test "published_templates should return all published templates" do
    3.times do |i|
      template = Template.create(org: @org, version: 1, title: "Testing #{i}")
      if i < 2
        template.published = true 
        template.save!
      end
    end
    
    assert_not @org.published_templates.select{|t| t.title == "Testing 0"}.empty?, "expected the 1st template to be included"
    assert_not @org.published_templates.select{|t| t.title == "Testing 1"}.empty?, "expected the 2nd template to be included"
    assert @org.published_templates.select{|t| t.title == "Testing 2"}.empty?, "expected the 3rd template to NOT be included"
  end
  
  # ---------------------------------------------------
  test "check_api_credentials removes all user api_tokens" do
    org = Org.last
    org.users.each do |user|
      user.api_token = '12345'
      user.save!
    end
    
    org.check_api_credentials
    org.reload
    
    org.users.each do |user|
      assert_equal "", user.api_token, "expected the api_token for #{user.name} to have been deleted"
    end
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    org = Org.create(name: 'testing', links: {"org":[]})
    assert_not org.id.nil?, "was expecting to be able to create a new Org: #{org.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    org.abbreviation = 'TEST'
    org.save!
    org.reload
    assert_equal 'TEST', org.abbreviation, "Was expecting to be able to update the abbreviation of the Org!"
    
    assert org.destroy!, "Was unable to delete the Org!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Users" do
    usr = User.create(email: 'test@testing.org', password: 'testing1234')
    verify_has_many_relationship(@org, usr, @org.users.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Templates" do
    tmplt = Template.new(title: 'Added through test', version: 1)
    verify_has_many_relationship(@org, tmplt, @org.templates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Customisations" do
    tmplt = Template.new(title: 'Testing template', version: 1)
    verify_has_many_relationship(@org, tmplt, @org.templates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with GuidanceGroups" do
    gg = GuidanceGroup.new(name: 'Tester')
    verify_has_many_relationship(@org, gg, @org.guidance_groups.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Annotations" do
    a = Annotation.new(question: Question.first, text: 'Test Annotation')
    verify_has_many_relationship(@org, a, @org.annotations.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with TokenPermissionTypes" do
    tpt = TokenPermissionType.new(token_type: 'testing')
    verify_has_many_relationship(@org, tpt, @org.token_permission_types.count)
  end

  # ---------------------------------------------------
  test "Guidance Group should be created after_create of the Org" do
    org = Org.create!(name: 'Testing Guidance Group for Org', abbreviation: 'TGG', links: {"org":[]})
    assert_equal org.guidance_groups.count, 1
    org.destroy! 
  end
end
