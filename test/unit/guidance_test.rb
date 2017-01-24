require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase

  setup do
    Organisation.create(name: GlobalHelpers.constant("organisation_types.managing_organisation"))
    
    @user = User.first
    
    @guidance_group = GuidanceGroup.create(name: 'Tester', organisation: @user.organisation)
    @guidance = Guidance.create(text: 'Testing some new guidance')
    
    @guidance_group.guidances << @guidance
    @guidance_group.save!
    
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
  test "correctly identifies guidance as belonging to the organisation" do
    assert @guidance.in_group_belonging_to?(@user.organisation.id), "expected the guidance to belong to the organisation"
    
    @guidance.guidance_groups = []
    @guidance.save!

    assert_not @guidance.in_group_belonging_to?(@user.organisation), "expected the guidance to NOT belong to the organisation"
  end

  # ---------------------------------------------------
  test "retrieves guidance by organisation" do
    org = Organisation.create(name: 'Tester 123')
    assert Guidance.by_organisation(org.id).empty?, "expected the newly created organisation to have no guidance"

    assert_not Guidance.by_organisation(@user.organisation.id).empty?, "expected the organisation to have guidance"
  end

  # ---------------------------------------------------
  test "correctly identifies whether the user can view the guidance" do
    g = Guidance.create(text: 'Unviewable guidance')
    
    assert_not Guidance.can_view?(@user, g.id), "expected guidance that is not attached to a GuidanceGroup to be unviewable"
    
    managing = Organisation.find_by(name: GlobalHelpers.constant("organisation_types.managing_organisation"))
    funder = Organisation.find_by(organisation_type: OrganisationType.find_by( name: GlobalHelpers.constant("organisation_types.funder")))
    
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to their organisation"
    
    @guidance_group.organisation = managing
    @guidance_group.save!
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to the managing organisation"
    
    @guidance_group.organisation = funder
    @guidance_group.save!
    assert Guidance.can_view?(@user, @guidance.id), "expected the user to be able to view guidance belonging to a funder"
  end

  # ---------------------------------------------------
  test "make sure a user can view all appropriate guidance" do
    viewable = Guidance.all_viewable(@user)
    
    assert viewable.include?(@guidance), "expected the user to be able to view guidance belonging to their organisation"
    
    managing = Organisation.find_by(name: GlobalHelpers.constant("organisation_types.managing_organisation"))
    funder = Organisation.find_by(organisation_type: OrganisationType.find_by( name: GlobalHelpers.constant("organisation_types.funder")))
    
    GuidanceGroup.create(name: 'managing guidance group test', organisation: managing)
    GuidanceGroup.create(name: 'funder guidance group test', organisation: funder)
    
    managing.guidance_groups.each do |gg|
      gg.guidances.each do |g|
        assert viewable.include?(g), "expected the user to be able to view all managing organisation guidance"
      end
    end
    
    funder.guidance_groups.each do |gg|
      gg.guidances.each do |g|
        assert viewable.include?(g), "expected the user to be able to view all funder guidance"
      end
    end
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