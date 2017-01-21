require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase

  setup do
    @guidance = Guidance.new(text: 'Testing some new guidance')
    
    @question = Question.first
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Guidance.new.valid?
    assert_not Guidance.new(guidance_groups: [GuidanceGroup.first]).valid?, "expected the 'text' field to be required"

    # Ensure the bar minimum and complete versions are valid
    a = Guidance.new(text: 'Testing guidance')
    assert a.valid?, "expected the 'text' field to be enough to create a Guidance! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "can CRUD Guidance" do
    g = Guidance.create(text: 'Testing guidance')
    assert_not g.id.nil?, "was expecting to be able to create a new Guidance!"

    g.text = 'Testing an update'
    g.save!
    g.reload
    assert_equal 'Testing an update', g.text, "Was expecting to be able to update the text of the Guidance!"
  
    assert g.destroy!, "Was unable to delete the Guidance!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with GuidanceGroup" do
    gg = GuidanceGroup.new(name: 'Test Group', organisation: Organisation.first)
    verify_has_many_relationship(@guidance, gg, @guidance.guidance_groups.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Theme" do
    t = Theme.new(title: 'Test Theme')
    verify_has_many_relationship(@guidance, t, @guidance.themes.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Question" do
    verify_belongs_to_relationship(@guidance, @question)
  end  
end