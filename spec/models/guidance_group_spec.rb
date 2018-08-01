require 'rails_helper'

RSpec.describe GuidanceGroup, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to allow_value(true).for(:optional_subset)  }

    it { is_expected.to allow_value(true).for(:published) }

    it { is_expected.to allow_value(false).for(:optional_subset)  }

    it { is_expected.to allow_value(false).for(:published) }

  end

  context "associations" do

    it { is_expected.to belong_to :org }

    it { is_expected.to have_many :guidances }

  end

  describe ".can_view?" do

    let!(:user) { create(:user) }

    let!(:guidance_group) { create(:guidance_group) }

    subject { GuidanceGroup.can_view?(user, guidance_group) }


    context "when owned by an Org which the user is a member" do

      let!(:guidance_group) { create(:guidance_group, org: user.org) }

      it { is_expected.to eql(true) }

    end

    context "when owned by a curation center" do

      let!(:org) do
        create(:org,
          abbreviation: Rails.configuration
                             .branding.dig(:organisation, :abbreviation))
      end

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it { is_expected.to eql(true) }

    end

    context "when owned by a institution org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :institution))
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a funder org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :funder))
      end

      it { is_expected.to eql(true) }

    end

    context "when owned by a organisation org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :organisation))
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a research_institute org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :research_institute))
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a project org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :project))
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a school org" do

      let!(:guidance_group) do
        create(:guidance_group, org: create(:org, :school))
      end

      it { is_expected.to eql(false) }

    end
  end

  describe ".all_viewable" do

    let!(:user) { create(:user) }

    subject { GuidanceGroup.all_viewable(user) }

    context "when is owned by managing curation center" do

      let!(:org) do
        create(:org,
          abbreviation: Rails.configuration
                             .branding.dig(:organisation, :abbreviation))
      end

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "includes guidance group" do
        expect(subject).to include(guidance_group)
      end

    end

    context "when is owned by institution Org" do

      let!(:org) { create(:org, :institution) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "excludes guidance group" do
        expect(subject).not_to include(guidance_group)
      end

    end

    context "when is owned by funder Org" do

      let!(:org) { create(:org, :funder) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "includes guidance group" do
        expect(subject).to include(guidance_group)
      end

    end

    context "when is owned by organisation Org" do

      let!(:org) { create(:org, :organisation) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "excludes guidance group" do
        expect(subject).not_to include(guidance_group)
      end

    end

    context "when is owned by research_institute Org" do

      let!(:org) { create(:org, :research_institute) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "excludes guidance group" do
        expect(subject).not_to include(guidance_group)
      end

    end

    context "when is owned by project Org" do

      let!(:org) { create(:org, :project) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "excludes guidance group" do
        expect(subject).not_to include(guidance_group)
      end

    end

    context "when is owned by school Org" do

      let!(:org) { create(:org, :school) }

      let!(:guidance_group) { create(:guidance_group, org: org) }

      it "excludes guidance group" do
        expect(subject).not_to include(guidance_group)
      end

    end
  end

  describe "#display_name" do

    # Creates a default GuidanceGroup when Org is created
    let!(:org) { create(:org) }

    let!(:guidance_group) { org.guidance_groups.first }

    context "when org has many guidance_groups" do

      before do
        create(:guidance_group, org: org)
      end

      it "returns the org name and group name" do
        result = "#{org.name}: #{guidance_group.name}"
        expect(guidance_group.display_name).to eql(result)
      end

    end

    context "when org has one guidance group (self)" do

      it "returns the Org name" do
        expect(guidance_group.display_name).to eql(org.name)
      end

    end
  end

end
