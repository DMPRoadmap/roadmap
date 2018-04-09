require 'test_helper'

class GuidanceGroupTest < ActiveSupport::TestCase
  include GlobalHelpers
  
  setup do
    @user = User.first
    @org = Org.last
    # First clear out any existing templates
    GuidanceGroup.all.each do |gg|
      gg.destroy!
    end  
    @guidance_group = GuidanceGroup.create(name: 'Test Guidance Group', org: @org,
                                           optional_subset: false, published: true)
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not GuidanceGroup.new.valid?
    assert_not GuidanceGroup.new(org: @org).valid?, "expected the 'name' field to be required"
    assert_not GuidanceGroup.new(name: 'Tester').valid?, "expected the 'organisation' field to be required"

    # Ensure the bar minimum and complete versions are valid
    a = GuidanceGroup.new(name: 'Tester', org: @org)
    assert a.valid?, "expected the 'name' and 'organisation' fields to be enough to create a GuidanceGroup! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "display_name returns organisation name and the guidance group name" do
    assert_equal "#{@org.name}", @guidance_group.display_name, "Expected display_name to return the organisation name if there is only one GuidanceGroup"
    
    GuidanceGroup.create(name: 'Second Test', org: @org)
    assert_equal "#{@org.name}: #{@guidance_group.name}", @guidance_group.display_name, "Expected display_name to return the organisation name and guidance group name if there are more than one GuidanceGroup"
  end

  # ---------------------------------------------------
  test "guidance_groups_excluding does not return guidance groups for the current organisation" do
    assert_not GuidanceGroup.guidance_groups_excluding([@org]).include?(@guidance_group), "expected the exclusion to work for an array of orgs"
    assert_not GuidanceGroup.guidance_groups_excluding(@org).include?(@guidance_group), "expected the exclusion to work for a single org"
  end

  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to their organisation" do
    org = @user.org
    gg = GuidanceGroup.create(name: 'User Test', org: org)
    
    assert GuidanceGroup.can_view?(@user, gg)
  end

  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to a funder" do
    gg = GuidanceGroup.create(name: 'Funder Test', org: Org.funder.first)
    
    assert GuidanceGroup.can_view?(@user, gg)
  end
  
  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to the managing curation centre" do
    gg = GuidanceGroup.create(name: 'Managing CC Test', org: Org.managing_orgs.first)
    
    assert GuidanceGroup.can_view?(@user, gg)
  end

  # ---------------------------------------------------
  test "user can view all oftheir organisations, funders, and the managing curation centre's guidance groups" do
    @org.users << @user
    @org.save
    @org.reload

    ggs = [@guidance_group,
           GuidanceGroup.create(name: 'User Test', org: @org),
           GuidanceGroup.create(name: 'Funder Test', org: Org.funder.first),
           GuidanceGroup.create(name: 'Managing CC Test', org: Org.managing_orgs.first)]
    
    v = GuidanceGroup.all_viewable(@user)
    
    ggs.each do |gg|
      assert v.include?(gg), "expected Guidance Group: '#{gg.name}' to be viewable"
    end
  end

  # ---------------------------------------------------
  test "can CRUD GuidanceGroup" do
    gg = GuidanceGroup.create(name: 'Tester', org: @org)
    assert_not gg.id.nil?, "was expecting to be able to create a new GuidanceGroup!"

    gg.name = 'Testing an update'
    gg.save!
    gg.reload
    assert_equal 'Testing an update', gg.name, "Was expecting to be able to update the text of the GuidanceGroup!"
  
    assert gg.destroy!, "Was unable to delete the GuidanceGroup!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Guidance" do
    g = Guidance.new(text: 'Test Guidance')
    verify_has_many_relationship(@guidance_group, g, @guidance_group.guidances.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Org" do
    verify_belongs_to_relationship(@guidance_group, @org)
  end  

end
