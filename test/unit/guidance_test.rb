require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase

  setup do
    @user = User.first

    @guidance_group = GuidanceGroup.create(name: 'Tester', org: @user.org)
    @guidance = Guidance.create(text: 'Testing some new guidance')
    
    @guidance_group.guidances << @guidance
    @guidance_group.save!
    
    @question = Question.first
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not Guidance.new.valid?
    assert_not Guidance.new(guidance_group: GuidanceGroup.first).valid?, "expected the 'text' field to be required"

    # Ensure the bar minimum and complete versions are valid
    a = Guidance.new(text: 'Testing guidance')
    assert a.valid?, "expected the 'text' field to be enough to create a Guidance! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end

  # ---------------------------------------------------
  test "correctly identifies guidance as belonging to the org" do
    assert @guidance.in_group_belonging_to?(@user.org.id), "expected the guidance to belong to the org"
    
    @guidance.guidance_group = nil
    @guidance.save!

    assert_not @guidance.in_group_belonging_to?(@user.org), "expected the guidance to NOT belong to the org"
  end

  # ---------------------------------------------------
  test "retrieves guidance by org" do
    org = Org.create!(name: 'Tester 123', abbreviation: 'TEST', org_type: 1, links: {"org":[]})
    assert Guidance.by_org(org).empty?, "expected the newly created org to have no guidance"

    assert_not Guidance.by_org(@user.org).empty?, "expected the org to have guidance"
  end

  # ---------------------------------------------------
  test "correctly identifies whether the user can view the guidance" do
    g = Guidance.create(text: 'Unviewable guidance')
    
    assert_not Guidance.can_view?(@user, g.id), "expected guidance that is not attached to a GuidanceGroup to be unviewable"
    
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to their org"
    
    @guidance_group.org = Org.managing_orgs.first
    @guidance_group.save!
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to the managing org"
    
    @guidance_group.org = Org.funder.first
    @guidance_group.save!
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to a funder"
  end

  # ---------------------------------------------------
  test "make sure a user can view all appropriate guidance" do
    viewable = Guidance.all_viewable(@user)
    
    assert viewable.include?(@guidance), "expected the user to be able to view guidance belonging to their org"
        
    GuidanceGroup.create(name: 'managing guidance group test', org: Org.managing_orgs.first)
    GuidanceGroup.create(name: 'funder guidance group test', org: Org.funder.first)
    
    Org.managing_orgs.first.guidance_groups.first.guidances.each do |g|
      assert viewable.include?(g), "expected the user to be able to view all managing org guidance"
    end
    
    Org.funder.first.guidance_groups.first.guidances.each do |g|
      assert viewable.include?(g), "expected the user to be able to view all funder guidance"
    end
  end
  
  # ---------------------------------------------------
  test "make sure all templates associated with the guidance are returned" do
    # TODO: is this method even appropriate?
  end

  # ---------------------------------------------------
  test "can CRUD Guidance" do
    g = Guidance.create(text: 'Testing guidance')
    assert_not g.id.nil?, "was expecting to be able to create a new Guidance!"

    g.text = 'Testing an update'
    g.save!
    g.reload
    assert_equal 'Testing an update', g.text, "Was expecting to be able to update the text of the Guidance!"
  
    # TODO: Uncomment this once the deprecated guidance-guidance_group relationship has been removed from Guidance
    #assert g.destroy!, "Was unable to delete the Guidance!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Theme" do
    t = Theme.new(title: 'Test Theme')
    verify_has_many_relationship(@guidance, t, @guidance.themes.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with GuidanceGroup" do
    gg = GuidanceGroup.new(name: 'Test GuidanceGroup', org: Org.last, published: true)
    verify_belongs_to_relationship(@guidance, gg)
  end  
end