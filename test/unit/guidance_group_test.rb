require 'test_helper'

class GuidanceGroupTest < ActiveSupport::TestCase
  # ---------- can_view? ----------
  test "DCC guidance groups should be viewable" do
    assert GuidanceGroup.can_view?(users(:user_one), guidance_groups(:dcc_guidance_group_1))
  end

  test "Funder guidance groups should be viewable" do
    organisation_types(:funder).organisations.each do |org|
      org.guidance_groups.each do |funder_group|
        assert GuidanceGroup.can_view?(users(:user_one), funder_group)
      end
    end
  end

  test "User's organisation groups should be viewable" do
    assert GuidanceGroup.can_view?(users(:user_one), guidance_groups(:institution_guidance_group_1).id) , "user_one cannot view aru_institution_guidance"

    assert GuidanceGroup.can_view?(users(:user_two), guidance_groups(:institution_guidance_group_2).id), "user_two cannot view au_..._1"

    assert GuidanceGroup.can_view?(users(:user_three), guidance_groups(:institution_guidance_group_3).id), "user_three cannot view bu_..._1"
    assert GuidanceGroup.can_view?(users(:user_three), guidance_groups(:institution_guidance_group_4).id), "user_three cannot view bu_..._2"
  end

  test "No other organisations's groups should be viewable"  do
    assert_not GuidanceGroup.can_view?(users(:user_one), guidance_groups(:institution_guidance_group_2).id)
    assert_not GuidanceGroup.can_view?(users(:user_one), guidance_groups(:institution_guidance_group_3).id)
    assert_not GuidanceGroup.can_view?(users(:user_one), guidance_groups(:institution_guidance_group_4).id)

    assert_not GuidanceGroup.can_view?(users(:user_two), guidance_groups(:institution_guidance_group_1).id)
    assert_not GuidanceGroup.can_view?(users(:user_two), guidance_groups(:institution_guidance_group_3).id)
    assert_not GuidanceGroup.can_view?(users(:user_two), guidance_groups(:institution_guidance_group_4).id)

    assert_not GuidanceGroup.can_view?(users(:user_three), guidance_groups(:institution_guidance_group_1).id)
    assert_not GuidanceGroup.can_view?(users(:user_three), guidance_groups(:institution_guidance_group_2).id)
  end


  # ---------- all_viewable ----------
  # ensure that the all_viewable function returns all viewable groups
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "all_viewable returns all dcc groups" do
    all_viewable_groups = GuidanceGroup.all_viewable(users(:user_one))
    organisations(:dcc).guidance_groups.each do |group|
      assert_includes(all_viewable_groups, group)
    end
  end

  test "all_viewable returns all funder groups" do
    all_viewable_groups = GuidanceGroup.all_viewable(users(:user_one))
    organisation_types(:funder).organisations.each do |org|
      org.guidance_groups.each do |group|
        assert_includes(all_viewable_groups, group)
      end
    end
  end

  test "all_viewable returns all of a user's organisations's guidances" do 
    all_viewable_groups_one = GuidanceGroup.all_viewable(users(:user_one))
    organisations(:aru).guidance_groups.each do |group|
      assert_includes(all_viewable_groups_one, group)
    end

    all_viewable_groups_two = GuidanceGroup.all_viewable(users(:user_two))
    organisations(:au).guidance_groups.each do |group|
      assert_includes(all_viewable_groups_two, group)
    end

    all_viewable_groups_three = GuidanceGroup.all_viewable(users(:user_three))
    organisations(:bu).guidance_groups.each do |group|
      assert_includes(all_viewable_groups_three, group)
    end
  end

  test "all_viewable does not return any other organisaition's guidance" do
    all_viewable_groups = GuidanceGroup.all_viewable(users(:user_one))
    all_viewable_groups.delete_if do |group|
      if group.organisation.id == organisations(:dcc).id
        true
      elsif group.organisation.organisation_type.id == organisation_types(:funder).id
        true
      elsif group.organisation.id == users(:user_one).organisations.first.id
        true
      else
        false
      end
    end
    assert_empty(all_viewable_groups)
  end


  # ---------- display_name ----------
  test "display_name should return an org name for an org with one guidance" do
    assert_equal(guidance_groups(:funder_guidance_group_1).display_name, "Arts and Humanities Research Council", "result of display_name for an org with one group should be the org name")
  end

  test "display_name should return an org and group name for an org with more than one guidance" do
    assert_equal(guidance_groups(:institution_guidance_group_4).display_name, "Bangor University: Bangor University guidance group 2", "result of display_name for an org with more than one group should be <org_name>: <group_name>")
  end

  # ---------- self.guidance_groups_excluding ----------
  test "guidance_groups_excluding should not return a group belonging to specified single org" do
    # generate a list
    excluding_list = GuidanceGroup.guidance_groups_excluding([organisations(:dcc)])
    excluding_list.each do |group|
      refute_equal(group.organisation, organisations(:dcc), "#{group.name} is owned by dcc")
    end
  end

  test "guidance_groups_excluding should not return a group belonging to specified orgs" do
    org_list = [organisations(:ahrc), organisations(:bu)]
    excluding_list = GuidanceGroup.guidance_groups_excluding(org_list)
    excluding_list.each do |group|
      org_list.each do |org|
        refute_equal(group.organisation, org, "#{group.name} is owned by specified org: #{org.name}")
      end
    end
  end

  test "guidance_groups_excluding should return all groups not belonging to the specified org" do
    excluding_list = GuidanceGroup.guidance_groups_excluding([organisations(:dcc)])
    GuidanceGroup.all.each do |group|
      if group.organisation_id != organisations(:dcc).id
        assert_includes(excluding_list, group, "#{group.name} is not owned by dcc so should be included")
      end
    end
  end

  test "guidance_groups_excluding should return all groups not belonging to specified orgs" do
    excluded =false
    org_list = [organisations(:ahrc), organisations(:bu)]
    excluding_list = GuidanceGroup.guidance_groups_excluding(org_list)
    GuidanceGroup.all.each do |group|
      excluded = false
      org_list.each do |org|
        if group.organisation == org
          excluded = true
        end
      end
      unless excluded
        assert_includes(excluding_list, group, "#{group.name} is not owned by a specified org so should be included")
      end
    end
  end

end






