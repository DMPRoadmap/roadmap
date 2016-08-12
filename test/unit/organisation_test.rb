require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase

  # ---------- short_name ----------
  test "short_name should return the abbreviation if it exists" do
    assert_equal(organisations(:dcc).short_name, organisations(:dcc).abbreviation, "Org: DCC has an abreviation and should return it")
  end

  test "short_name should return the name if no abbreviation exists" do
    assert_equal(organisations(:aru).short_name, organisations(:aru).name, "Org: ARU has no abbreviation and should return it's full name")
  end

  # ---------- self.orgs_with_parent_of_type ----------
  test "self.orgs_with_parent_of_type correctly identifies organisation trees" do
    children = Organisation.orgs_with_parent_of_type("institution")
    assert_includes(children, organisations(:institution_child_one), "Org: institution_child_one is a child of an institution")
  end

  # ---------- self.other_organisations ----------
  test "self.other_organisations correctly returns ___" do

  end

  # ---------- all_sections ----------
  test "all_sections returns correct sections" do
    sections = organisations(:dcc).all_sections(versions(:DCC_phase_1_version_1).id)
    org_sections = Section.find_by(organisation: organisations(:dcc))
    org_sections.each do |section|
      if section.version_id == versions(:DCC_phase_1_version_1).id
        assert_includes(sections, section, "Section: #{section.title} should be included")
      end
    end
  end

  test "all_sections returns a parents sections" do
    sections = organisations(:institution_child_one).all_sections(versions(:institution_child_version_1).id)
    assert_includes( sections, sections(:institution_parent_1), "all_sections should return it's parent's sections")
    assert_includes( sections, sections(:institution_parent_2), "all_sections should return it's parent's sections")
  end

  test "all_sections returns [] if no sections are found" do
    sections = organisations(:dcc).all_sections(versions(:institution_child_version_1).id)
    assert_empty( sections, "no sections of that version exist")
  end

  # ---------- all_guidance_groups ----------
  test "all_guidance_groups returns all of the organisations guidance groups" do
    all_groups = organisations(:dcc).all_guidance_groups
    organisations(:dcc).guidance_groups.each do |group|
      assert_includes(all_groups, group, "group: #{group.name} belongs to the specified org")
    end
  end

  test "all_guidance_groups returns all of the organisations children's guidance groups" do
    all_groups = organisations(:institution_parent).all_guidance_groups
    organisations(:institution_child_one).guidance_groups.each do |group|
      assert_includes(all_groups, group, "group: #{group.name} belongs to the specified org")
    end
  end

  # ---------- root ----------
  test "root correctly identifies the parent organisation" do
    assert_equal(organisations(:institution_child_one).root, organizations(:institution_parent), "institution parent is the parent of institution child one")
  end

  test "root returns self if an organisation has no parents" do
    assert_equal(organisations(:dcc).root, organisations(:dcc), "dcc has no parent, so is root")
  end

  # ---------- warning ----------
  test "warning returns specified warning if not nil" do
    flunk
  end

  test "warning returns the parent's warning if nil" do
    flunk
  end

  # ---------- published_templates ----------
  test "published_templates returns all owned and published templates" do
    flunk
  end

end
