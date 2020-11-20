# frozen_string_literal: true

require "rails_helper"

RSpec.describe Perm, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it {
      is_expected.to validate_uniqueness_of(:name)
        .with_message("must be unique")
    }
  end

  context "associations" do

    it { is_expected.to have_and_belong_to_many(:users) }

  end

  describe ".add_orgs" do

    subject { Perm.add_orgs }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".change_affiliation" do

    subject { Perm.change_affiliation }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".grant_permissions" do

    subject { Perm.grant_permissions }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".modify_templates" do

    subject { Perm.modify_templates }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".modify_guidance" do

    subject { Perm.modify_guidance }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".use_api" do

    subject { Perm.use_api }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".change_org_details" do

    subject { Perm.change_org_details }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api") }

      it { is_expected.not_to eql(perm) }

    end

  end

  describe ".grant_api" do

    subject { Perm.grant_api }

    context "when name is 'add_orgs'" do

      let!(:perm) { create(:perm, name: "add_organisations") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_affiliation'" do

      let!(:perm) { create(:perm, name: "change_org_affiliation") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_permissions'" do

      let!(:perm) { create(:perm, name: "grant_permissions") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_templates'" do

      let!(:perm) { create(:perm, name: "modify_templates") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'modify_guidance'" do

      let!(:perm) { create(:perm, name: "modify_guidance") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'use_api'" do

      let!(:perm) { create(:perm, name: "use_api") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'change_org_details'" do

      let!(:perm) { create(:perm, name: "change_org_details") }

      it { is_expected.not_to eql(perm) }

    end

    context "when name is 'grant_api'" do

      let!(:perm) { create(:perm, name: "grant_api_to_orgs") }

      it { is_expected.to eql(perm) }

    end
  end

end
