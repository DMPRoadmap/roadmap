require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase
  # ensure that the can_view function returns true all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "DCC guidances should be viewable" do
    guidance_groups(:dcc_guidance_group_1).guidances.each do |guidance|
      assert Guidance.can_view(users(:user_one), guidance.id)
    end
  end

  test "Funder guidances should be viewable" do
    assert Guidance.can_view(users(:user_one), guidances(:ahrc_funder_guidance).id)
    assert Guidance.can_view(users(:user_one), guidances(:bbsrc_funder_guidance).id)
  end


  test "User's organisation guidances should be viewable" do
    assert Guidance.can_view(users(:user_one), guidances(:aru_institution_guidance).id) , "user_one cannot view aru_institution_guidance"

    assert Guidance.can_view(users(:user_two), guidances(:au_institution_guidance_1).id), "user_two cannot view au_..._1"
    assert Guidance.can_view(users(:user_two), guidances(:au_institution_guidance_2).id), "user_two cannot view au_..._2"

    assert Guidance.can_view(users(:user_three), guidances(:bu_institution_guidance_1).id), "user_three cannot view bu_..._1"
    assert Guidance.can_view(users(:user_three), guidances(:bu_institution_guidance_2).id), "user_three cannot view bu_..._2"
  end


  test "No other organisations's guidances should be viewable" do
    # TOOD: add more fixtures with new types of guidances(i.e. not institution)
    # and add test cases

    assert_not Guidance.can_view(users(:user_one), guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view(users(:user_one), guidances(:au_institution_guidance_2).id)
    assert_not Guidance.can_view(users(:user_one), guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view(users(:user_one), guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view(users(:user_two), guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view(users(:user_two), guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view(users(:user_two), guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view(users(:user_three), guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view(users(:user_three), guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view(users(:user_three), guidances(:au_institution_guidance_2).id)
  end




  # ensure that the all_viewable function returns all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "all_viewable returns all DCC guidances" do
    all_viewable_guidances = Guidance.all_viewable(users(:user_one))
    guidance_groups(:dcc_guidance_group_1).guidances.each do |guidance|
      assert_includes(all_viewable_guidances, guidance)
    end
  end

  test "all_viewable returns all funder guidances" do
    all_viewable_guidances = Guidance.all_viewable(users(:user_one))
    guidance_groups(:funder_guidance_group_1).guidances.each do |guidance|
      assert_includes(all_viewable_guidances, guidance)
    end
    guidance_groups(:funder_guidance_group_2).guidances.each do |guidance|
      assert_includes(all_viewable_guidances, guidance)
    end
  end


  test "all_viewable returns all of a user's organisations's guidances" do
    all_viewable_guidances_one = Guidance.all_viewable(users(:user_one))
    organisations(:aru).guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_one, guidance)
      end
    end

    all_viewable_guidances_two = Guidance.all_viewable(users(:user_two))
    organisations(:au).guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_two, guidance)
      end
    end

    all_viewable_guidances_three = Guidance.all_viewable(users(:user_three))
    organisations(:bu).guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances_three, guidance)
      end
    end
  end


  test "all_viewable does not return any other organisation's guidance" do
    # TODO: Add in a suitable test.  should we check for non-institutions?
    all_viewable_guidances = Guidance.all_viewable(users(:user_one))
    # remove all of the user's organisation
    # remove all of each funder's organisations
    # remove each of the dcc's organisations
    # check if nill
    all_viewable_guidances.delete_if do |guidance|
      guidance.guidance_groups.each do |group|
        if group.organisation.id == organisations(:dcc).id
          return true
        elsif group.organisation.organisation_type.id == organisation_types(:funder).id
          return true
        elsif group.organisation.id == users(:user_one).organisations.first.id
          return true
        end
        return false
      end
    end
    assert_nil(all_viewable_guidances, "there must not be any guidances which are not funders, DCC, or our own organisation")
  end
end








