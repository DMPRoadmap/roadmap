require 'test_helper'

class GuidanceTest < ActiveSupport::TestCase
  # ---------- can_view? ----------
  # ensure that the can_view? function returns true all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "DCC guidances should be viewable" do
    guidance_groups(:dcc_guidance_group_1).guidances.each do |guidance|
      assert Guidance.can_view?(users(:user_one), guidance.id)
    end
  end

  test "Funder guidances should be viewable" do
    assert Guidance.can_view?(users(:user_one), guidances(:ahrc_funder_guidance).id)
    assert Guidance.can_view?(users(:user_one), guidances(:bbsrc_funder_guidance).id)
  end


  test "User's organisation guidances should be viewable" do
    assert Guidance.can_view?(users(:user_one), guidances(:aru_institution_guidance).id) , "user_one cannot view aru_institution_guidance"

    assert Guidance.can_view?(users(:user_two), guidances(:au_institution_guidance_1).id), "user_two cannot view au_..._1"
    assert Guidance.can_view?(users(:user_two), guidances(:au_institution_guidance_2).id), "user_two cannot view au_..._2"

    assert Guidance.can_view?(users(:user_three), guidances(:bu_institution_guidance_1).id), "user_three cannot view bu_..._1"
    assert Guidance.can_view?(users(:user_three), guidances(:bu_institution_guidance_2).id), "user_three cannot view bu_..._2"
  end

  test "No other organisations's guidances should be viewable" do
    # TOOD: add more fixtures with new types of guidances(i.e. not institution)
    # and add test cases
    assert_not Guidance.can_view?(users(:user_one), guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view?(users(:user_one), guidances(:au_institution_guidance_2).id)
    assert_not Guidance.can_view?(users(:user_one), guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view?(users(:user_one), guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view?(users(:user_two), guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view?(users(:user_two), guidances(:bu_institution_guidance_1).id)
    assert_not Guidance.can_view?(users(:user_two), guidances(:bu_institution_guidance_2).id)

    assert_not Guidance.can_view?(users(:user_three), guidances(:aru_institution_guidance).id)
    assert_not Guidance.can_view?(users(:user_three), guidances(:au_institution_guidance_1).id)
    assert_not Guidance.can_view?(users(:user_three), guidances(:au_institution_guidance_2).id)
  end

# ---------- all_viewable ----------
  # ensure that the all_viewable function returns all viewable guidances
  #   should return true for groups owned by funders
  #   should return true for groups owned by DCC
  #   should return true for groups owned by the user's organisation
  #   should not return true for an organisation outwith those above
  test "all_viewable returns all DCC guidances" do
    all_viewable_guidances = Guidance.all_viewable(users(:user_one))
    organisations(:dcc).guidance_groups.each do |group|
      group.guidances.each do |guidance|
        assert_includes(all_viewable_guidances, guidance)
      end
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
          true
        elsif group.organisation.organisation_type.id == organisation_types(:funder).id
          true
        elsif group.organisation.id == users(:user_one).organisations.first.id
          true
        else
          false
        end
      end
    end
    assert_empty(all_viewable_guidances, "there must not be any guidances which are not funders, DCC, or our own organisation")
  end

  # ---------- in_group_belonging_to? ----------
  test "in_group_belonging_to correctly identifies parent orgs" do
    # test that the association works for all correct usages
    Guidance.all.each do |guidance|
      guidance.guidance_groups.each do |group|
        assert(guidance.in_group_belonging_to?(group.organisation.id), "Guidance: #{guidance.text} should belong to organisation #{group.organisation.name}")
      end
    end
  end

  test "in_group_belonging_to rejects non-parent orgs" do
    # test that in_group_belonging_to rejects a few interesting organisation-guidance pairs
    assert_not(guidances(:related_policies).in_group_belonging_to?(organisations(:ahrc)), "Organisation ahrc does not own guidance: related policies")
    assert_not(guidances(:ahrc_funder_guidance).in_group_belonging_to?(organisations(:dcc)), "Organisation dcc does not own guidance: ahrc_funder_guidance")
  end

  # ---------- by_organisation ----------
  test "by_organisation correctly returns all guidance belonging to a given org" do
    Organisation.all.each do |org|
      org_guidance = Guidance.by_organisation(org)
      org.guidance_groups.each do |group|
        group.guidances.each do |guidance|
          assert_includes(org_guidance, guidance, "Guidance #{guidance.text} should belong to organisation: #{org.name}")
        end
      end
    end
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








