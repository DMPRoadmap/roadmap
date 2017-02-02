require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_plan
    
    @role = Role.create(user: User.first, plan: @plan, access: 1)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Role.new.valid?
    assert_not Role.new(user: @user, plan: Plan.first).valid?, "expected the 'access' field to be required"
    assert_not Role.new(plan: Plan.first, access: 1).valid?, "expected the 'user' field to be required"
    assert_not Role.new(user: @user, access: 1).valid?, "expected the 'plan' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    plan = Plan.create(title: 'Test Plan', template: Template.last)
    a = Role.new(user: @user, plan: plan, access: 1)
    assert a.valid?, "expected the 'user', 'plan' and 'access' fields to be enough to create an Role! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "cannot have more than one role per User+Plan" do
    @user.roles << Role.new(plan: @plan, access: 2)
    assert_not @user.valid?, "Expected to NOT be able to add more than one role for the same user/plan"
    
    plan = Plan.create(title: 'Test Plan', template: Template.last)
    @user.roles << Role.new(plan: plan, access: 3)
    assert @user.valid?, "Expected to be able to add a role for the same user but a different plan"
  end
  
  # ---------------------------------------------------
  test "access_level acts a proxy to the 'access' flagshihtzu bit flag field" do
 
    puts @role.inspect
    
    assert @role.creator?, "expected the role to be creator"
    
    @role.administrator = true
    assert @role.administrator?, "expected the role to be administrator after setting 'administrator'"
    @role.administrator = false

    @role.access_level = 3
    assert @role.administrator?, "expected the role to be administrator after setting 'access_level' >= 3"
  end
  
  # ---------------------------------------------------
  test "can CRUD Role" do
    plan = Plan.create(title: 'Test Plan', template: Template.last)
    obj = Role.create(user: @user, plan: plan, access: 1)
    assert_not obj.id.nil?, "was expecting to be able to create a new Role: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.access = 2
    obj.save!
    obj.reload
    assert_equal 2, obj.access, "Was expecting to be able to update the text of the Role!"
  
    assert obj.destroy!, "Was unable to delete the Role!"
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with User" do
    role = Role.new(plan: Plan.first, access: 3)
    verify_belongs_to_relationship(role, User.first)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Plan" do
    role = Role.new(user: User.first, access: 3)
    verify_belongs_to_relationship(role, Plan.first)
  end
  
end