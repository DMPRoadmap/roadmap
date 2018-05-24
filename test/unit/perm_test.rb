require 'test_helper'

class PermTest < ActiveSupport::TestCase
  setup do
    @user = User.last
    
    @perm = Perm.create(name: 'testing')
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Perm.new.valid?
    
    # Ensure the bare minimum and complete versions are valid
    a = Perm.new(name: 'Testing 2')
    assert a.valid?, "expected the 'name' field to be enough to create an Perm! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "name field must be unique" do
    assert_not Perm.new(name: 'testing').valid?
  end
  
  # ---------------------------------------------------
  test "can CRUD Perm" do
    obj = Perm.create(name: 'Tested ABC')
    assert_not obj.id.nil?, "was expecting to be able to create a new Perm: #{obj.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

    obj.name = 'Testing an update'
    obj.save!
    obj.reload
    assert_equal 'Testing an update', obj.name, "Was expecting to be able to update the name of the Perm!"
  
    assert obj.destroy!, "Was unable to delete the Perm!"
  end
    
  # ---------------------------------------------------
  test "can manage has_many relationship with User" do
    verify_has_many_relationship(@perm, @user, @perm.users.count)
  end
  
end
