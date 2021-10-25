# frozen_string_literal: true

require "rails_helper"

RSpec.describe GuidanceGroup, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to allow_value(true).for(:optional_subset) }

    it { is_expected.to allow_value(true).for(:published) }

    it { is_expected.to allow_value(false).for(:optional_subset) }

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
               abbreviation: Rails.configuration.x.organisation.abbreviation)
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
               abbreviation: Rails.configuration.x.organisation.abbreviation)
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

    context ":merge!(to_be_merged:)" do
      before(:each) do
        org = create(:org)
        @guidance_group = create(:guidance_group, org: org)
        @to_be_merged = create(:guidance_group, org: org, plans: [create(:plan)],
                                                guidances: [create(:guidance)])
      end

      it "returns false if to_be_merged is not a GuidanceGroup" do
        result = @guidance_group.merge!(to_be_merged: build(:user))
        expect(result).to eql(@guidance_group)
      end
      it "occurs inside a transaction" do
        GuidanceGroup.any_instance.stubs(:save).returns(false)
        result = @guidance_group.merge!(to_be_merged: @to_be_merged)
        expect(result).to eql(nil)
        # Since the save will fail and we reload the Object it should be valid
        expect(@guidance_group.valid?).to eql(true)
        expect(@to_be_merged.reload.new_record?).to eql(false)
        expect(@to_be_merged.guidances.length).not_to eql(0)
      end
      it "merges associated :plans" do
        expected = @guidance_group.plans.length + @to_be_merged.plans.length
        @guidance_group.merge!(to_be_merged: @to_be_merged)
        expect(@guidance_group.plans.length).to eql(expected)
      end
      it "merges associated :guidances" do
        expected = @guidance_group.guidances.length + @to_be_merged.guidances.length
        @guidance_group.merge!(to_be_merged: @to_be_merged)
        expect(@guidance_group.guidances.length).to eql(expected)
      end
      it "removes the :to_be_merged GuidanceGroup" do
        original_id = @to_be_merged.id
        expect(@guidance_group.merge!(to_be_merged: @to_be_merged)).to eql(@guidance_group)
        expect(Guidance.where(guidance_group_id: original_id).any?).to eql(false)
        expect(GuidanceGroup.find_by(id: original_id).present?).to eql(false)
      end
    end

  end
end
