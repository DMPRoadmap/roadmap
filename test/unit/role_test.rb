require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_plan
    
    @role = Role.create(user: User.first, plan: @plan)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Role.new.valid?
    assert_not Role.new(plan: Plan.first, access: 1).valid?, "expected the 'user' field to be required"
    assert_not Role.new(user: @user, access: 1).valid?, "expected the 'plan' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    plan = Plan.create(title: 'Test Plan', template: Template.last)
    a = Role.new(user: @user, plan: plan)
    assert a.valid?, "expected the 'user', 'plan' and 'access' fields to be enough to create an Role! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "access is properly defaulted" do
    assert_equal 1, @role.access_level
  end
  
  # ---------------------------------------------------
  test "access_level acts a proxy to the 'access' FlagShihTzu bit flag field" do
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
    obj = Role.create(user: @user, plan: plan, access_level: 1)
    assert_not obj.id.nil?, "was expecting to be able to create a new Role: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.access_level = 2
    obj.save!
    obj.reload
    assert_equal 2, obj.access_level, "Was expecting to be able to update the text of the Role!"
  
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