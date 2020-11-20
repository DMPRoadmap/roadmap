# frozen_string_literal: true

require "rails_helper"

RSpec.describe Guidance, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:text) }

    it { is_expected.to validate_presence_of(:guidance_group) }

    context "if published" do

      before { subject.expects(:published?).returns(true) }
      it { is_expected.to validate_presence_of(:themes) }

    end

    it { is_expected.to allow_value(true).for(:published) }

    it { is_expected.to allow_value(false).for(:published) }

  end

  context "associations" do

    it { is_expected.to belong_to :guidance_group }

    it do
      is_expected.to have_and_belong_to_many(:themes)
        .join_table("themes_in_guidance")
    end
  end

  describe ".can_view?" do

    let!(:user) { create(:user) }

    subject { Guidance.can_view?(user, @guidance.id) }

    context "when guidance_id is invalid" do

      before do
        @guidance = Guidance.new(guidance_group: create(:guidance_group))
      end

      it { is_expected.to eql(false) }

    end

    context "when guidance's group is nil" do

      before do
        @guidance = Guidance.new
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a curation center" do

      before do
        @org = create(:org,
                      abbreviation: Rails.configuration.x.organisation.abbreviation)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(true) }

    end

    context "when owned by a institution org" do

      before do
        @org            = create(:org, :institution)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a funder org" do

      before do
        @org            = create(:org, :funder)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(true) }

    end

    context "when owned by a organisation org" do

      before do
        @org            = create(:org, :organisation)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a research_institute org" do

      before do
        @org            = create(:org, :research_institute)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a project org" do

      before do
        @org            = create(:org, :project)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by a school org" do

      before do
        @org            = create(:org, :school)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(false) }

    end

    context "when owned by an Org which the user is a member" do

      before do
        @org            = user.org
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it { is_expected.to eql(true) }

    end

  end

  describe ".all_viewable" do

    let!(:user) { create(:user) }

    subject { Guidance.all_viewable(user) }

    context "when is owned by managing curation center" do

      before do
        @org = create(:org,
                      abbreviation: Rails.configuration.x.organisation.abbreviation)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "includes guidance" do
        expect(subject).to include(@guidance)
      end

    end

    context "when is owned by institution Org" do

      before do
        @org = create(:org, :institution)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "excludes guidance" do
        expect(subject).not_to include(@guidance)
      end

    end

    context "when is owned by funder Org" do

      before do
        @org = create(:org, :funder)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "includes guidance" do
        expect(subject).to include(@guidance)
      end

    end

    context "when is owned by organisation Org" do

      before do
        @org = create(:org, :organisation)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "excludes guidance" do
        expect(subject).not_to include(@guidance)
      end

    end

    context "when is owned by research_institute Org" do

      before do
        @org = create(:org, :research_institute)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "excludes guidance" do
        expect(subject).not_to include(@guidance)
      end

    end

    context "when is owned by project Org" do

      before do
        @org = create(:org, :project)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "excludes guidance" do
        expect(subject).not_to include(@guidance)
      end

    end

    context "when is owned by school Org" do

      before do
        @org = create(:org, :school)
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "excludes guidance" do
        expect(subject).not_to include(@guidance)
      end

    end

    context "when is owned by User's Org'" do

      before do
        @org = user.org
        @guidance_group = create(:guidance_group, org: @org)
        @guidance       = create(:guidance, guidance_group: @guidance_group)
      end

      it "includes guidance" do
        expect(subject).to include(@guidance)
      end

    end
  end

  describe "#in_group_belonging_to?" do

    let!(:org) { create(:org) }

    subject { guidance.in_group_belonging_to?(org.id) }

    context "when guidance_group is nil" do

      let!(:guidance) { Guidance.new }

      it { is_expected.to eql(false) }

    end

    context "when guidance group belongs to given Org" do

      let!(:guidance_group) { create(:guidance_group, org: org) }

      let!(:guidance) { create(:guidance, guidance_group: guidance_group) }

      it { is_expected.to eql(true) }

    end

    context "when guidance group doesn't belong to given Org" do

      let!(:guidance_group) { create(:guidance_group) }

      let!(:guidance) { create(:guidance, guidance_group: guidance_group) }

      it { is_expected.to eql(false) }

    end
  end

end
