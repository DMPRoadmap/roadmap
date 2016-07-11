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

  # would be better to instead start with dcc and find all attached guidances?
  # I think so so I will impliment here and back-impliment to guidances
  # TODO: impliment in guidances
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
end






