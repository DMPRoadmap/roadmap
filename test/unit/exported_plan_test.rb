require 'test_helper'

class ExportedPlanTest < ActiveSupport::TestCase

  setup do
    @user = User.last
    
    scaffold_plan
    
    @exported = ExportedPlan.create(user: @user, plan: @plan, 
                                    format: ExportedPlan::VALID_FORMATS.first)
  end

  # ---------------------------------------------------
  test "required fields are required" do
    assert_not ExportedPlan.new.valid?
    assert_not ExportedPlan.new(format: ExportedPlan::VALID_FORMATS.last).valid?, "expected the 'plan' field to be required"
    assert_not ExportedPlan.new(plan: @plan).valid?, "expected the 'format' field to be required"
    
    # Ensure the bar minimum and complete versions are valid
    a = ExportedPlan.new(plan: @plan, format: ExportedPlan::VALID_FORMATS.last)
    assert a.valid?, "expected the 'plan', 'user' and 'format' fields to be enough to create an ExportedPlan! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end


  # ---------------------------------------------------
  test "as_csv" do
    
  end

  # ---------------------------------------------------
  test "as_txt" do
    
  end
    
  # ---------------------------------------------------
  test "can CRUD ExportedPlan" do
    ExportedPlan::VALID_FORMATS.each do |vf|
      ep = ExportedPlan.create(user: @user, plan: @plan, format: vf)
      assert_not ep.id.nil?, "was expecting to be able to create a new ExportedPlan: #{ep.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"

      expected = (vf == ExportedPlan::VALID_FORMATS.last ? ExportedPlan::VALID_FORMATS.first : ExportedPlan::VALID_FORMATS.last)

      ep.format = expected
      ep.save!
      ep.reload
      assert_equal expected, ep.format, "Was expecting to be able to update the format of the ExportedPlan!"
    
      assert ep.destroy!, "Was unable to delete the ExportedPlan!"
    end
  end
    
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Plan" do
    verify_belongs_to_relationship(@exported, Plan.last)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with User" do
    verify_belongs_to_relationship(@exported, User.last)
  end
  
end
