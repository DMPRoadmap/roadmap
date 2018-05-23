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
                        org: Org.last,
                        api_token: 'ABC123',
                        language: Language.find_by(abbreviation: I18n.locale))

    @notification = Notification.create!(
      notification_type: Notification.notification_types[:global], 
      title: 'notification_1', 
      level: Notification.levels[:info],
      body: 'notification 1', 
      dismissable: false, 
      starts_at: Date.today, 
      expires_at: Date.tomorrow)
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
    # Name should return 'First Last' if we do not specify email
    assert @user.name(false).include?(@user.firstname), "expected the first name to be included when specifying non-email"
    assert @user.name(false).include?(@user.surname), "expected the last name to be included when specifying non-email"

    # Should return email if we do not pass in a variable
    assert_equal @user.email, @user.name, "expected the email by default"

    # Name should return the email if no first and last are present
    @user.firstname = nil
    @user.surname = nil
    assert_equal @user.email, @user.name(false), "expected the email if there is no first and last name"
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
      #assert super_admins.first.send(auth), "expected that Super Admin #{auth}"
      assert_not org_admins.first.send(auth), "did NOT expect that Organisation Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end

    # Organisational Admin - permission checks
    org_admin_methods.each do |auth|
      #assert super_admins.first.send(auth), "expected that the Super Admin #{auth}"
      #assert org_admins.first.send(auth), "expected that the Organisational Admin #{auth}"
      assert_not @user.send(auth), "did NOT expect that User #{auth}"
    end
  end

  # ---------------------------------------------------
  test "new user is active by default" do
    assert @user.active?
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
  test "can find a user via an OAuth response" do
    scheme = IdentifierScheme.create!(name: 'tester', active: true)
    @user.user_identifiers << UserIdentifier.new(identifier_scheme: scheme, identifier: '12345')
    @user.save!

    class Auth
      def provider
        "tester"
      end
      def uid
        "12345"
      end
    end

    assert_equal @user, User.from_omniauth(Auth.new)

    class UnknownAuth
      def provider
        "unknown"
      end
      def uid
        "12345"
      end
    end

    assert_raise "'Unknown OAuth provider: unknown" do
      User.from_omniauth(UnknownAuth.new)
    end
  end

  # ---------------------------------------------------
  test "Plans query filter is working properly" do
    3.times do |i|
      plan = Plan.create(title: "My test #{i}", template: @template, visibility: 1)
      @user.roles << Role.new(plan: plan, access: 1)
    end
    @user.save!

    plan = @user.plans.filter("2").first
    assert_equal "My test 2", plan.title, "Expected the plans filter to search the title"
  end

  # ---------------------------------------------------
  test "Returns the appropriate identifier for the specified scheme" do
    3.times do |i|
      scheme = IdentifierScheme.create!({name: "test-#{i}", active: true})

      @user.user_identifiers << UserIdentifier.new(identifier_scheme: scheme, identifier: i.to_s)
    end
    @user.save!

    3.times do |i|
      scheme = IdentifierScheme.find_by(name: "test-#{i}")

      assert_equal i.to_s, @user.identifier_for(scheme).identifier, "expected the identifier for #{scheme.name} to be '#{i.to_s}'"
    end
  end

  # ---------------------------------------------------
  test "can_super_admin is properly set" do
    perms = Perm.where('name IN (?)', ['add_organisations', 'change_org_affiliation', 'grant_api_to_orgs'])
    user = User.create!(email: 'tester@example.edu', password: 'password')

    assert_not user.can_super_admin?, "expected a user with no permissions to NOT be a super_admin"

    perms.each do |p|
      last = p
      user.perms.delete(last) unless last.nil?
      user.perms << p
      user.save!

      assert user.can_super_admin?, "expected the addition of the #{p.name} perm to enable the user to become a super_admin"
    end

    user.perms = []
    user.save!

    user.perms = perms
    user.save!
    assert user.can_super_admin?, "expected the addition of all the super_admin perms to allow the user to be a super_admin"
  end

  # ---------------------------------------------------
  test "can_org_admin is properly set" do
    perms = Perm.where('name IN (?)', ['grant_permissions', 'modify_templates', 'modify_guidance', 'change_org_details'])
    user = User.create!(email: 'tester@example.edu', password: 'password')

    assert_not user.can_org_admin?, "expected a user with no permissions to NOT be a org_admin"

    perms.each do |p|
      last = p
      user.perms.delete(last) unless last.nil?
      user.perms << p
      user.save!

      assert user.can_org_admin?, "expected the addition of the #{p.name} perm to enable the user to become a org_admin"
    end

    user.perms = []
    user.save!

    user.perms = perms
    user.save!
    assert user.can_org_admin?, "expected the addition of all the super_admin perms to allow the user to be a org_admin"
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
  test "can manage has_many relationship with Roles" do
    role = Role.new(plan: @plan, access: 1)
    verify_has_many_relationship(@user, role, @user.roles.count)
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
    org = Org.new(name: 'Tester', abbreviation: 'TST', links: {"org":[]})
    verify_belongs_to_relationship(@user, org)
  end

  # ---------------------------------------------------
  test "can manage belongs_to relationship with Language" do
    language = Language.new(name: 'esperonto', abbreviation: 'zz')
    verify_belongs_to_relationship(@user, language)
  end
  test "after_save removes API token and its perms associated" do
    previous_api_token = @user.api_token
    @user.perms = [Perm.add_orgs, Perm.grant_permissions]
    previous_perms = @user.perms.to_a 
    @user.org = Org.where.not(id: @user.org_id).first
    @user.save
    assert_not_equal(previous_api_token, @user.api_token)
    assert_not_equal(previous_perms, @user.perms.to_a)
  end
  test "after_save does not remove API token and its perms associated if user can_change_org" do
    previous_api_token = @user.api_token
    @user.perms = [Perm.add_orgs, Perm.grant_permissions, Perm.change_affiliation]
    previous_perms = @user.perms
    @user.org = Org.where.not(id: @user.org_id).first
    @user.save
    assert_equal(previous_api_token, @user.api_token)
    assert_equal(previous_perms, @user.perms)
  end

  # Cannot dismiss Notifications that are non-dismissable
  test 'cannot acknowledge a notification that is not dismissable' do
    @user.acknowledge(@notification)
    assert_not(@notification.acknowledged?(@user))
  end
  # Can dismiss Notifications that are dismissable
  test 'can acknowledge a notification' do
    @notification.update!(dismissable: true)
    @user.acknowledge(@notification)
    assert(@notification.acknowledged?(@user))
  end
end
