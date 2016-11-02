require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @super = users(:cc_super)
    @funder = users(:funder_admin)
    @user = users(:complete_user)
    
    @organisation = organisations(:curation_center)
    @language = languages(I18n.default_locale)
    
    @dmptemplate = dmptemplates(:cc_template)
    
    @complete = User.new(email: 'me@example.edu', 
                         password: 'password',
                         firstname: 'Test',
                         surname: 'User',
                         orcid_id: 'test-orcid',
                         shibboleth_id: 'test-shib',
                         accept_terms: 'true',
                         organisation: @organisation,
                         api_token: 'ABC123',
                         language: @language)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not User.new.valid?
    assert_not User.new(password: 'password').valid?
    assert_not User.new(email: 'me@example.org').valid?
    assert_not User.new(firstname: 'test', surname: 'user').valid?
    assert_not User.new(firstname: 'test', surname: 'user', password: 'password').valid?
    assert_not User.new(firstname: 'test', surname: 'user', email: 'me@example.org').valid?
    
    # Ensure the bar minimum and complete versions are valid
    assert User.new(email: 'me@example.edu', password: 'password').valid?
    assert @complete.valid?
  end

  # ---------------------------------------------------
  test "password must be at least 8 characters" do
    assert_not User.new(email: 'me@example.org', password: 'pass').valid?
    assert_not User.new(email: 'me@example.org', password: 'pass12').valid?
    assert_not User.new(email: 'me@example.org', password: 'Pass12').valid?
    assert_not User.new(email: 'me@example.org', password: 'Pass12*').valid?
    
    assert User.new(email: 'me@example.org', password: 'Password12*').valid?
    assert User.new(email: 'me@example.org', password: 'passwords').valid?
    assert User.new(email: 'me@example.org', password: 'Password').valid?
  end

  # ---------------------------------------------------
  test "name returns the correct value" do
    # Name should return 'First Last'
    assert @super.name.include?(@super.firstname)
    assert @super.name.include?(@super.surname)
    
    # Name should return the email if no first and last are present
    @super.firstname = nil
    @super.surname = nil
    assert_equal @super.email, @super.name
  end

  # ---------------------------------------------------
  test "only accepts valid email addresses" do
    assert @super.valid?
    
    @super.email = 'testing'
    assert_not @super.valid?
    @super.email = 'testing.tester.org'
    assert_not @super.valid?
    @super.email = 'testing@tester'
    assert_not @super.valid?
    
    @super.email = 'testing@tester.org'
    assert @super.valid?
  end

  # ---------------------------------------------------
  test "has default Settings::PlanList" do
    assert_not_equal [], @super.settings(:plan_list).columns
  end
  
  # ---------------------------------------------------
  test "api token gets removed" do
    @super.api_token = 'ABCDEFGHIJKLMNOP'
    @super.save!
    assert_equal 'ABCDEFGHIJKLMNOP', @super.reload.api_token, "expected the api_token to have been initialized"
    
    @super.remove_token!
    assert_equal '', @super.reload.api_token, "expected the api_token to have been removed"
  end
  
  # ---------------------------------------------------
  test "api token gets kept or created" do
    @super.api_token = 'ABCDEFGHIJKLMNOP'
    @super.save!
    assert_equal 'ABCDEFGHIJKLMNOP', @super.reload.api_token, "expected the api_token to have been initialized"
    
    @super.keep_or_generate_token!
    assert_equal 'ABCDEFGHIJKLMNOP', @super.reload.api_token, "expected the api_token to have been kept"

    @super.remove_token!
    assert_equal '', @super.reload.api_token, "expected the api_token to have been removed"
    
    @super.keep_or_generate_token!
    assert_not_equal '', @super.reload.api_token, "expected the api_token to have been generated"
  end
  
  # ---------------------------------------------------
  test "responds to all of the authentication options" do
    admin = [:can_add_orgs?, :can_change_org?, :can_grant_api_to_orgs?]
    
    org_admin = [:can_grant_permissions?, :can_modify_templates?, 
                 :can_modify_guidance?, :can_use_api?, :can_modify_org_details?]
          
    [:can_super_admin?, :can_org_admin?].each do |auth|
      assert_respond_to @super, auth, "expected User to respond to #{auth}"
    end
    
    # Super Admin - permission checks
    admin.each do |auth|
      assert @super.send(auth), "expected that Super Admin #{auth}"
      assert_not @funder.send(auth), "did NOT expect that Organisation Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end
    
    # Organisational Admin - permission checks
    org_admin.each do |auth|
      assert @super.send(auth), "expected that the Super Admin #{auth}"
      assert @funder.send(auth), "expected that the Organisational Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end
  end
  
  # ---------------------------------------------------
  test "can CRUD" do
    usr = User.create(email: 'test@testing.org', password: 'testing1234')
    assert_not usr.id.nil?, "was expecting to be able to create a new User: #{usr.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    usr.firstname = 'Tester'
    usr.save!
    usr.reload
    assert_equal 'Tester', usr.firstname, "Was expecting to be able to update the firstname of the User!"
    
    assert usr.destroy!, "Was unable to delete the User!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Dmptemplates" do
    tmplt = Dmptemplate.new(title: 'Added through test')
    verify_has_many_relationship(@funder, tmplt, @funder.dmptemplates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Roles" do
    role = Role.new(name: 'Added through test')
    verify_has_many_relationship(@super, role, @super.roles.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Projects" do
    # TODO: need to change dmptemplate_id to dmptemplate after refactor of Project
    project = Project.new(title: 'Test Project', dmptemplate_id: @dmptemplate.id)
    verify_has_many_relationship(@super, project, @super.projects.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Answers" do
    # TODO: many need to remove this once we revise/remove locking
    project = Project.new(title: 'Test Project', dmptemplate_id: @dmptemplate.id)
    plan = Plan.new(project: project)
    question = Question.new(text: 'testing question')
    answer = Answer.new(plan: plan, question: question)
    verify_has_many_relationship(@super, answer, @super.answers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with PlanSections" do
    # TODO: many need to remove this once we revise/remove locking
    project = Project.new(title: 'Test Project', dmptemplate_id: @dmptemplate.id)
    plan = Plan.new(project: project)
    section = Section.new()
    ps = PlanSection.new(plan: plan, section: section)
    verify_has_many_relationship(@super, ps, @super.plan_sections.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Organisation" do
    verify_belongs_to_relationship(@super, @organisation)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Language" do
    verify_belongs_to_relationship(@super, @language)
  end

end
