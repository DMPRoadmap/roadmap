require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  setup do
    @org = organisations(:curation_center)
    
    @org_type = OrganisationType.last
    @language = languages(I18n.default_locale)
  end
  
  # ---------- required fields are required ------------
  test "required fields should be required" do
    org = Organisation.new
    assert_not(org.valid?)
    
    org.name = 'ABCD'
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
  test "only accepts valid contact_email addresses" do
    assert @org.valid?
    
    @org.contact_email = 'testing'
    assert_not @org.valid?
    @org.contact_email = 'testing.tester.org'
    assert_not @org.valid?
    @org.contact_email = 'testing@tester'
    assert_not @org.valid?
    
    @org.contact_email = 'testing@tester.org'
    assert @org.valid?
  end
  
  # ---------------------------------------------------
  test "should resize logo to a height of 100" do
    ['logo.jpg', # this one is at 160x160
     'logo_300x300.jpg', 
     'logo_100x100.jpg'].each do |file|
       
       path = File.expand_path("../../assets/#{file}", __FILE__)
       @org.logo = Dragonfly.app.fetch_file("#{path}")
       
       assert @org.valid?, "expected the logo to have been attached to the organisation"
       assert_equal 100, @org.logo.height, "expected the logo to have been resized properly"
    end
  end
  
  # ---------------------------------------------------
  test "should remove all associated User's api tokens if no TokenPermissionTypes are present" do
    @org.token_permission_types << token_permission_types(:plans_token_type)
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
    # for the organisation have been removed
    #@org.token_permission_types.clear
    #@org.save!
    #usr = @org.reload.users.find_by(email: 'tester@testing.org')
    #assert_equal nil, usr.api_token
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    org = Organisation.create(name: 'testing')
    assert_not org.id.nil?, "was expecting to be able to create a new Organisation: #{org.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    org.abbreviation = 'TEST'
    org.save!
    org.reload
    assert_equal 'TEST', org.abbreviation, "Was expecting to be able to update the abbreviation of the Organisation!"
    
    assert org.destroy!, "Was unable to delete the Organisation!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Users" do
    usr = User.create(email: 'test@testing.org', password: 'testing1234')
    verify_has_many_relationship(@org, usr, @org.users.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Dmptemplates" do
    tmplt = Dmptemplate.new(title: 'Added through test')
    verify_has_many_relationship(@org, tmplt, @org.dmptemplates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Customisations" do
    tmplt = Dmptemplate.new(title: 'Testing template')
    verify_has_many_relationship(@org, tmplt, @org.dmptemplates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with GuidanceGroups" do
    gg = GuidanceGroup.new(name: 'Tester')
    verify_has_many_relationship(@org, gg, @org.guidance_groups.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with OptionWarnings" do
    ow = OptionWarning.new(text: 'Test', option: Option.first)
    verify_has_many_relationship(@org, ow, @org.option_warnings.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with SuggestedAnswers" do
    sa = SuggestedAnswer.new(question: Question.first, text: 'Test Suggested Answer')
    verify_has_many_relationship(@org, sa, @org.suggested_answers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with TokenPermissionTypes" do
    tpt = TokenPermissionType.new(token_type: 'testing')
    verify_has_many_relationship(@org, tpt, @org.token_permission_types.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with OrganisationType" do
    verify_belongs_to_relationship(@org, @org_type)
  end
  
end
