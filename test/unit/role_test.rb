require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_plan
    
    @role = Role.create(user: User.first, plan: @plan, access: 15)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Role.new.valid?
    assert_not Role.new(plan: Plan.first, access: 1).valid?, "expected the 'user' field to be required"
    assert_not Role.new(user: @user, access: 1).valid?, "expected the 'plan' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    plan = Plan.create(title: 'Test Plan', template: Template.last, visibility: :is_test)
    a = Role.new(user: @user, plan: plan, access: 15)
    assert a.valid?, "expected the 'user', 'plan' and 'access' fields to be enough to create an Role! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "access is properly defaulted" do
    assert_equal 15, @role.access
  end
  
  # ---------------------------------------------------
  test "FlagShihTzu bit flag fields are properly mapped" do
    assert @role.creator?, "expected the role to be creator"
    
    @role.administrator = true
    assert @role.administrator?, "expected the role to be administrator after setting 'administrator'"
    @role.administrator = false

    [1, 3, 5, 7, 9, 11, 13, 15].each do |a|
      @role.access = a
      assert @role.creator?, "expected the role to be creator after setting 'access_level' >= #{a}"
    end
    
    [2, 3, 6, 7, 10, 11, 14, 15].each do |a|
      @role.access = a
      assert @role.administrator?, "expected the role to be administrator after setting 'access_level' >= #{a}"
    end
    
    [4, 5, 6, 7, 12, 13, 14, 15].each do |a|
      @role.access = a
      assert @role.editor?, "expected the role to be editor after setting 'access_level' >= #{a}"
    end
    
    [8, 9, 10, 11, 12, 13, 14, 15].each do |a|
      @role.access = a
      assert @role.commenter?, "expected the role to be commenter after setting 'access_level' >= #{a}"
    end
  end
  
  # ---------------------------------------------------
  test "can CRUD Role" do
    plan = Plan.create(title: 'Test Plan', template: Template.last, visibility: :is_test)
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