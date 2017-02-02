require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    scaffold_plan
    
    @user = User.create(email: 'me@example.edu', 
                        password: 'password',
                        password_confirmation: 'password',
                        firstname: 'Test',
                        surname: 'User',
                        shibboleth_id: 'test-shib',
                        accept_terms: 'true',
                        organisation: Org.last,
                        api_token: 'ABC123',
                        language: Language.find_by(abbreviation: I18n.locale))
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
    a = User.new(email: 'me_testing@example.edu', password: 'password')
    assert a.valid?, "expected 'email' and 'password' to be enough to create a User - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
    assert @user.valid?
  end

  # ---------------------------------------------------
  test "email address must be unique" do
    assert_not User.new(email: 'me@example.edu', password: 'password').valid?
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
    assert @user.name.include?(@user.firstname)
    assert @user.name.include?(@user.surname)
    
    # Name should return the email if no first and last are present
    @user.firstname = nil
    @user.surname = nil
    assert_equal @user.email, @user.name
  end

  # ---------------------------------------------------
  test "only accepts valid email addresses" do
    assert @user.valid?
    
    @user.email = 'testing'
    assert_not @user.valid?
    @user.email = 'testing.tester.org'
    assert_not @user.valid?
    @user.email = 'testing@tester'
    assert_not @user.valid?
    
    @user.email = 'testing@tester.org'
    assert @user.valid?
  end

  # ---------------------------------------------------
  test "has default Settings::PlanList" do
    assert_not_equal [], @user.settings(:plan_list).columns
  end
  
  # ---------------------------------------------------
  test "api token is removed after call to remove_token" do
    @user.api_token = 'ABCDEFGHIJKLMNOP'
    @user.save!
    assert_equal 'ABCDEFGHIJKLMNOP', @user.reload.api_token, "expected the api_token to have been initialized"
    
    @user.remove_token!
    assert_equal '', @user.reload.api_token, "expected the api_token to have been removed"
  end
  
  # ---------------------------------------------------
  test "api token gets kept or created" do
    @user.api_token = 'ABCDEFGHIJKLMNOP'
    @user.save!
    assert_equal 'ABCDEFGHIJKLMNOP', @user.reload.api_token, "expected the api_token to have been initialized"
    
    @user.keep_or_generate_token!
    assert_equal 'ABCDEFGHIJKLMNOP', @user.reload.api_token, "expected the api_token to have been kept"

    @user.remove_token!
    assert_equal '', @user.reload.api_token, "expected the api_token to have been removed"
    
    @user.keep_or_generate_token!
    assert_not_equal '', @user.reload.api_token, "expected the api_token to have been generated"
  end
  
  # ---------------------------------------------------
  test "responds to all of the authentication options" do
    super_admins = User.joins(:perms).where('perms.name = ?', 'add_organisations').to_a
    org_admins = User.joins(:perms).where('perms.name = ?', 'modify_templates').to_a
    users = User.includes(:perms).where(perms: {id: nil}).to_a
        
    # remove all of the users who also have super_admin privileges
    org_admins = org_admins.delete_if{|u| super_admins.include?(u) }

    admin_methods = [:can_add_orgs?, :can_change_org?, :can_grant_api_to_orgs?]
    
    org_admin_methods = [:can_grant_permissions?, :can_modify_templates?, 
                         :can_modify_guidance?, :can_use_api?, :can_modify_org_details?]
          
    [:can_super_admin?, :can_org_admin?].each do |auth|
      assert_respond_to super_admins.first, auth, "expected User to respond to #{auth}"
    end
    
    # Super Admin - permission checks
    admin_methods.each do |auth|
      assert super_admins.first.send(auth), "expected that Super Admin #{auth}"
      assert_not org_admins.first.send(auth), "did NOT expect that Organisation Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end
    
    # Organisational Admin - permission checks
    org_admin_methods.each do |auth|
      assert super_admins.first.send(auth), "expected that the Super Admin #{auth}"
      assert org_admins.first.send(auth), "expected that the Organisational Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end
  end
  
  # ---------------------------------------------------
  test "can only have one identifier per IdentifierScheme" do
    @scheme = IdentifierScheme.first
    
    count = @user.user_identifiers.count
    @user.user_identifiers << UserIdentifier.new(identifier_scheme: @scheme, identifier: 'abc')
    @user.save!
    @user.reload
    
    assert_equal (count + 1), @user.user_identifiers.count, "Expected the initial identifier to be saved"
    
    @user.user_identifiers << UserIdentifier.new(identifier_scheme: @scheme, identifier: 'abc')
    assert_not @user.valid?, "Expected to NOT be able to add more than one identifier for the same scheme"
    assert_equal (count + 1), @user.user_identifiers.count, "Expected the initial identifier to be saved"
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
  test "can manage has_many relationship with Perms" do
    perm = Perm.new(name: 'Added through test')
    verify_has_many_relationship(@user, perm, @user.perms.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with UserIdentifiers" do
    id = UserIdentifier.new(identifier_scheme: IdentifierScheme.first, identifier: 'tester')
    verify_has_many_relationship(@user, id, @user.user_identifiers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Plans" do
    plan = Plan.new(title: 'Test Project', template: @template)
    verify_has_many_relationship(@user, plan, @user.plans.count)
  end

  # ---------------------------------------------------
  test "can manage has_many relationship with Answers" do
    answer = Answer.new(plan: @plan, 
                        question: @plan.template.phases.first.sections.first.questions.first, 
                        text: 'Testing')
    verify_has_many_relationship(@user, answer, @user.answers.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Notes" do
    answer = Answer.create(plan: @plan, 
                        question: @plan.template.phases.first.sections.first.questions.first, 
                        text: 'Testing')
    note = Note.new(answer: answer, text: 'Testing')
    verify_has_many_relationship(@user, note, @user.notes.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with ExportedPlans" do
    plan = ExportedPlan.new(plan: @plan, format: ExportedPlan::VALID_FORMATS.last)
    verify_has_many_relationship(@user, plan, @user.exported_plans.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    org = Org.new(name: 'Tester', abbreviation: 'TST')
    verify_belongs_to_relationship(@user, org)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Language" do
    language = Language.new(name: 'esperonto', abbreviation: 'zz')
    verify_belongs_to_relationship(@user, language)
  end

end
