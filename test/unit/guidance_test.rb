<<<<<<< HEAD
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
=======
require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase

  setup do
    @user_one = User.first
    @user_two = User.order(surname: :desc).first
    @user_three = User.last
    
    @org_type = OrganisationType.first
    
    @organisations = Org.all
  end

  # ---------- can_view? ----------
  # ensure that the can_view? function returns true all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "DCC guidances should be viewable" do
=begin
    guidance_groups(:dcc_guidance_group_1).guidances.each do |guidance|
      assert Guidance.can_view?(@user_one, guidance.id)
    end
=end
  end

  test "Funder guidances should be viewable" do
=begin
    assert Guidance.can_view?(@user_one, guidances(:ahrc_funder_guidance).id)
    assert Guidance.can_view?(@user_one, guidances(:bbsrc_funder_guidance).id)
=end
  end


  test "User's organisation guidances should be viewable" do
=begin
    assert Guidance.can_view?(@user_one, guidances(:aru_institution_guidance).id) , "user_one cannot view aru_institution_guidance"

    assert Guidance.can_view?(@user_two, guidances(:au_institution_guidance_1).id), "user_two cannot view au_..._1"
    assert Guidance.can_view?(@user_two, guidances(:au_institution_guidance_2).id), "user_two cannot view au_..._2"

    assert Guidance.can_view?(@user_three, guidances(:bu_institution_guidance_1).id), "user_three cannot view bu_..._1"
    assert Guidance.can_view?(@user_three, guidances(:bu_institution_guidance_2).id), "user_three cannot view bu_..._2"
=end
  end

  test "No other organisations's guidances should be viewable" do
=begin
    # TOOD: add more fixtures with new types of guidances(i.e. not institution)
    # and add test cases
    assert_not Guidance.can_view?(@user_one, guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view?(@user_one, guidances(:au_institution_guidance_2).id)
    assert_not Guidance.can_view?(@user_one, guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view?(@user_one, guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view?(@user_two, guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view?(@user_two, guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view?(@user_two, guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view?(@user_three, guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view?(@user_three, guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view?(@user_three, guidances(:au_institution_guidance_2).id)
=end
  end

# ---------- all_viewable ----------
  # ensure that the all_viewable function returns all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "all_viewable returns all DCC guidances" do
=begin
    all_viewable_guidances = Guidance.all_viewable(@user_one)
    @organisations.first.guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances, guidance)
      end
    end
=end
  end

  test "all_viewable returns all funder guidances" do
=begin
    all_viewable_guidances = Guidance.all_viewable(@user_one)
    guidance_groups(:funder_guidance_group_1).guidances.each do |guidance|
      assert_includes(all_viewable_guidances, guidance)
    end
    guidance_groups(:funder_guidance_group_2).guidances.each do |guidance|
      assert_includes(all_viewable_guidances, guidance)
    end
=end
  end

  test "all_viewable returns all of a user's organisations's guidances" do
=begin
    all_viewable_guidances_one = Guidance.all_viewable(@user_one)
    @organisations.first.guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_one, guidance)
      end
    end

    all_viewable_guidances_two = Guidance.all_viewable(@user_two)
    @organisations[1].guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_two, guidance)
      end
    end

    all_viewable_guidances_three = Guidance.all_viewable(@user_three)
    @organisations.last.guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_three, guidance)
      end
    end
=end
  end


  test "all_viewable does not return any other organisation's guidance" do
=begin
    # TODO: Add in a suitable test.  should we check for non-institutions?
    all_viewable_guidances = Guidance.all_viewable(@user_one)
    # remove all of the user's organisation
    # remove all of each funder's organisations
    # remove each of the dcc's organisations
    # check if nill
    all_viewable_guidances.delete_if do |guidance|
      guidance.guidance_groups.each do |group|
        if group.organisation.id == organisations(:dcc).id
          true
        elsif group.organisation.organisation_type.id == organisation_types(:funder).id
          true
        elsif group.organisation.id == @user_one.organisations.first.id
          true
        else
          false
        end
      end
    end
    assert_empty(all_viewable_guidances, "there must not be any guidances which are not funders, DCC, or our own organisation")
=end
  end

  # ---------- in_group_belonging_to? ----------
  test "in_group_belonging_to correctly identifies parent orgs" do
=begin
    # test that the association works for all correct usages
    Guidance.all.each do |guidance|
      guidance.guidance_groups.each do |group|
        assert(guidance.in_group_belonging_to?(group.organisation.id), "Guidance: #{guidance.text} should belong to organisation #{group.organisation.name}")
      end
    end
=end
  end

  test "in_group_belonging_to rejects non-parent orgs" do
=begin
    # test that in_group_belonging_to rejects a few interesting organisation-guidance pairs
    assert_not(guidances(:related_policies).in_group_belonging_to?(organisations(:ahrc)), "Organisation ahrc does not own guidance: related policies")
    assert_not(guidances(:ahrc_funder_guidance).in_group_belonging_to?(organisations(:dcc)), "Organisation dcc does not own guidance: ahrc_funder_guidance")
=end
  end

  # ---------- by_organisation ----------
  test "by_organisation correctly returns all guidance belonging to a given org" do
=begin
    Org.all.each do |org|
      org_guidance = Guidance.by_organisation(org)
      org.guidance_groups.each do |group|
        group.guidances.each do |guidance|
          assert_includes(org_guidance, guidance, "Guidance #{guidance.text} should belong to organisation: #{org.name}")
        end
      end
    end
=end
  end

  # ---------- get_guidance_group_templates ----------
  ## the main function is completely bugged, so ask to remove it
  # test "get_guidance_group_templates retuns all templates belonging to a guidance group" do
  #   GuidanceGroup.all.each do |group|
  #     group_templates = guidances(:related_policies).get_guidance_group_templates?(group)
  #     group.dmptemplates.each do |template|
  #       assert_includes(group_templates, template, "group #{group.name} should include template #{template.title}")
  #     end
  #   end
  # end

end








>>>>>>> final_schema
