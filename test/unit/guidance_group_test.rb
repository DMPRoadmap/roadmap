require 'test_helper'

class GuidanceGroupTest < ActiveSupport::TestCase
  include GlobalHelpers
  
  setup do
    Organisation.create(name: GlobalHelpers.constant("organisation_types.managing_organisation"))
    
    @user = User.first
    @organisation = Organisation.first
    
<<<<<<< HEAD
    @guidance_group = GuidanceGroup.create(name: 'Test Guidance Group', 
                                           organisation: @organisation)
=======
    @organisations = Org.all
>>>>>>> final_schema
  end
  
  # ---------------------------------------------------
  test "required fields are required" do
    assert_not GuidanceGroup.new.valid?
    assert_not GuidanceGroup.new(organisation: @organisation).valid?, "expected the 'name' field to be required"
    assert_not GuidanceGroup.new(name: 'Tester').valid?, "expected the 'organisation' field to be required"

    # Ensure the bar minimum and complete versions are valid
    a = GuidanceGroup.new(name: 'Tester', organisation: @organisation)
    assert a.valid?, "expected the 'name' and 'organisation' fields to be enough to create a GuidanceGroup! - #{a.errors.map{|f, m| f.to_s + ' ' + m}.join(', ')}"
  end
  
  # ---------------------------------------------------
  test "display_name returns organisation name and the guidance group name" do
    assert_equal "#{@organisation.name}", @guidance_group.display_name, "Expected display_name to return the organisation name if there is only one GuidanceGroup"
    
    GuidanceGroup.create(name: 'Second Test', organisation: @organisation)
    assert_equal "#{@organisation.name}: #{@guidance_group.name}", @guidance_group.display_name, "Expected display_name to return the organisation name and guidance group name if there are more than one GuidanceGroup"
  end

  # ---------------------------------------------------
  test "to_s returns organisation name and the guidance group name" do
    assert_equal @guidance_group.display_name, @guidance_group.to_s
  end

  # ---------------------------------------------------
  test "guidance_groups_excluding does not return guidance groups for the current organisation" do
    assert_not GuidanceGroup.guidance_groups_excluding([@organisation]).include?(@guidance_group)
  end

  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to their organisation" do
    org = @user.organisation
    gg = GuidanceGroup.create(name: 'User Test', organisation: org)
    
    assert GuidanceGroup.can_view?(@user, gg.id)
  end

  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to a funder" do
    org = Organisation.find_by(organisation_type: OrganisationType.find_by(name: GlobalHelpers.constant("organisation_types.funder")))
    gg = GuidanceGroup.create(name: 'Funder Test', organisation: org)
    
    assert GuidanceGroup.can_view?(@user, gg.id)
  end
  
  # ---------------------------------------------------
  test "user can view guidance_group if it belongs to the managing curation centre" do
    org = Organisation.find_by(name: GlobalHelpers.constant("organisation_types.managing_organisation"))
    gg = GuidanceGroup.create(name: 'Managing CC Test', organisation: org)
    
    assert GuidanceGroup.can_view?(@user, gg.id)
  end

  # ---------------------------------------------------
  test "user can view all oftheir organisations, funders, and the managing curation centre's guidance groups" do
    @organisation.users << @user
    @organisation.save
    @organisation.reload

    funding = Organisation.where(organisation_type: OrganisationType.find_by(name: GlobalHelpers.constant("organisation_types.funder"))).first
    managing = Organisation.find_by(name: GlobalHelpers.constant("organisation_types.managing_organisation"))

    ggs = [@guidance_group,
           GuidanceGroup.create(name: 'User Test', organisation: @organisation),
           GuidanceGroup.create(name: 'Funder Test', organisation: funding),
           GuidanceGroup.create(name: 'Managing CC Test', organisation: managing)]
    
    v = GuidanceGroup.all_viewable(@user)
    
    ggs.each do |gg|
      assert v.include?(gg), "expected Guidance Group: '#{gg.name}' to be viewable"
    end
  end

  # ---------------------------------------------------
  test "can CRUD GuidanceGroup" do
    gg = GuidanceGroup.create(name: 'Tester', organisation: @organisation)
    assert_not gg.id.nil?, "was expecting to be able to create a new GuidanceGroup!"

    gg.name = 'Testing an update'
    gg.save!
    gg.reload
    assert_equal 'Testing an update', gg.name, "Was expecting to be able to update the text of the GuidanceGroup!"
  
    assert gg.destroy!, "Was unable to delete the GuidanceGroup!"
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Project" do
    proj = Project.new(title: 'Test Project', dmptemplate: Dmptemplate.first)
    verify_has_many_relationship(@guidance_group, proj, @guidance_group.projects.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Template" do
    t = Dmptemplate.new(title: 'Test Theme', organisation: @organisation)
    verify_has_many_relationship(@guidance_group, t, @guidance_group.dmptemplates.count)
  end
  
  # ---------------------------------------------------
  test "can manage has_many relationship with Guidance" do
    g = Guidance.new(text: 'Test Guidance')
    verify_has_many_relationship(@guidance_group, g, @guidance_group.guidances.count)
  end
  
  # ---------------------------------------------------
  test "can manage belongs_to relationship with Organisation" do
    verify_belongs_to_relationship(@guidance_group, @organisation)
  end  

end
