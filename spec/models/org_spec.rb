# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it {
      subject.name = "DMP Company"
      is_expected.to validate_uniqueness_of(:name)
        .with_message("must be unique")
    }

    it { is_expected.to validate_presence_of(:abbreviation) }

    it { is_expected.to allow_values(true, false).for(:is_other) }

    it { is_expected.not_to allow_value(nil).for(:is_other) }

    it { is_expected.to allow_values(0, 1).for(:managed) }

    it "validates presence of contact_email if feedback_enabled" do
      subject.feedback_enabled = true
      is_expected.to validate_presence_of(:contact_email)
    end

    it "doesn't validate presence of contact_email if feedback_enabled nil" do
      subject.feedback_enabled = false
      is_expected.not_to validate_presence_of(:contact_email)
    end

    # validates :contact_email, presence: { message: PRESENCE_MESSAGE,
    #                                       if: :feedback_enabled }
    #
    # validates :org_type, presence: { message: PRESENCE_MESSAGE }
    #
    # validates :feedback_enabled, inclusion: { in: BOOLEAN_VALUES,
    #                                           message: INCLUSION_MESSAGE }
    #
    # validates :feedback_email_subject, presence: { message: PRESENCE_MESSAGE,
    #                                                if: :feedback_enabled }
    #
    # validates :feedback_email_msg, presence: { message: PRESENCE_MESSAGE,
    #                                            if: :feedback_enabled }
    #
  end

  context "associations" do

    it { should belong_to(:language) }

    it { should belong_to(:region).optional }

    it { should have_many(:guidance_groups).dependent(:destroy) }

    it { should have_many(:templates) }

    it { should have_many(:users) }

    it { should have_many(:annotations) }

    # rubocop:disable Layout/LineLength
    it { should have_and_belong_to_many(:token_permission_types).join_table("org_token_permissions") }
    # rubocop:enable Layout/LineLength

    it { should have_many(:identifiers) }

    it { should have_many(:plans) }

    it { should have_many(:funded_plans) }
  end

  context "scopes" do
    before(:each) do
      @managed = create(:org, managed: true)
      @unmanaged = create(:org, managed: false)
    end

    describe ".default_orgs" do
      subject { Org.default_orgs }

      context "when Org has same abbr as dmproadmap.rb initializer setting" do

        let!(:org) do
          abbrev = Rails.configuration.x.organisation.abbreviation
          create(:org, abbreviation: abbrev)

        end

        it { is_expected.to include(org) }

      end

      context "when Org doesn't have same abbr as dmproadmap.rb initializer setting" do

        let!(:org) { create(:org, abbreviation: "foo-bar") }

        it { is_expected.not_to include(org) }

      end
    end

    describe "#managed" do
      it "returns only the managed orgs" do
        rslts = described_class.managed
        expect(rslts.include?(@managed)).to eql(true)
        expect(rslts.include?(@unmanaged)).to eql(false)
      end
    end
    describe "#unmanaged" do
      it "returns only the un-managed orgs" do
        rslts = described_class.unmanaged
        expect(rslts.include?(@managed)).to eql(false)
        expect(rslts.include?(@unmanaged)).to eql(true)
      end
    end
  end

  describe "#locale" do

    let!(:org) { build(:org) }

    subject { org.locale }

    context "language present" do

      it { is_expected.to be_present }

    end
  end

  describe "#org_type_to_s" do

    subject { org.org_type_to_s }

    context "no organisation present" do

      let!(:org) { build(:org) }

      it { is_expected.to eql("None") }

    end

    context "organisation present" do

      context "when single organisation type and organisation type is Institution" do

        let!(:org) { build(:org, :institution) }

        it { is_expected.to eql("Institution") }

      end

      context "when single organisation type and organisation type is Funder" do

        let!(:org) { build(:org, :funder) }

        it { is_expected.to eql("Funder") }

      end

      context "when single organisation type and organisation type is Organisation" do

        let!(:org) { build(:org, :organisation) }

        it { is_expected.to eql("Organisation") }

      end

      context "when single organisation type and organisation type is Research Institute" do

        let!(:org) { build(:org, :research_institute) }

        it { is_expected.to eql("Research Institute") }

      end

      context "when single organisation type and organisation type is Project" do

        let!(:org) { build(:org, :project) }

        it { is_expected.to eql("Project") }

      end

      context "when single organisation type and organisation type is School" do

        let!(:org) { build(:org, :school) }

        it { is_expected.to eql("School") }

      end

      context "when organisation has multiple organisation types" do

        let!(:org) { build(:org, :funder, :school) }

        it { is_expected.to include("Funder", "School") }

      end

    end
  end

  describe "#funder_only?" do

    let!(:org) { build(:org) }

    subject { org.funder_only? }

    context "when organistation type is only Funder" do

      before do
        org.funder = true
      end

      it { is_expected.to be true }

    end

    context "when multiple organistation types present" do

      before do
        org.institution = true
        org.funder = true
      end

      it { is_expected.to be false }

    end
  end

  describe "#to_s" do
    let!(:org) { build(:org) }

    subject { org.to_s }

    it { is_expected.to_not be_blank }

  end

  describe "short_name" do

    let!(:org) { build(:org) }

    subject { org.short_name }

    context "when abbreviation present" do

      it { is_expected.to_not be_blank }

    end

    context "when abbreviation absent" do

      before do
        org.abbreviation = nil
      end

      it { is_expected.to_not be_blank }

    end
  end

  describe "#published_templates" do

    let!(:org) { build(:org) }

    subject { org.published_templates }

    context "when template is published" do

      before do
        @template = create(:template, published: true, org: org)
      end

      it { is_expected.to include(@template) }

    end

    context "when template is not published" do
      before do
        @template = create(:template, published: false, org: org)
      end

      it { is_expected.not_to include(@template) }

    end
  end

  describe "#org_admins" do

    let!(:org) { create(:org) }
    let!(:user) { create(:user, org: org) }

    subject { org.org_admins }

    context "when user belongs to Org with perms absent" do

      before do
        @perm = create(:perm)
        user.org = org
      end

      it { is_expected.to be_empty }

    end

    context "when user belongs to Org with grant_permissions perm" do

      before do
        @perm = build(:perm)
        @perm.name = "grant_permissions"
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context "when user belongs to Org with modify_templates perm" do

      before do
        @perm = build(:perm)
        @perm.name = "modify_templates"
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context "when user belongs to Org with modify_guidance perm" do

      before do
        @perm = build(:perm)
        @perm.name = "modify_guidance"
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }
    end

    context "when user belongs to Org with change_org_details perm present " do

      before do
        @perm = build(:perm)
        @perm.name = "change_org_details"
        user.perms << @perm
      end

      it { is_expected.to_not be_empty }

    end
  end

  describe "#plans" do

    let!(:org) { create(:org) }
    let!(:plan) { create(:plan, org: org) }
    let!(:user) { create(:user, org: org) }

    subject { org.plans }

    context "when user belongs to Org and plan owner with role :creator" do

      before do
        create(:role, :creator, user: user, plan: plan)
        plan.add_user!(user.id, :creator)
      end

      it { is_expected.to include(plan) }

    end

    context "when user belongs to Org and plan user with role :administrator" do

      before do
        plan.add_user!(user.id, :administrator)
      end

      it {
        is_expected.to include(plan)
      }

    end

    context "user belongs to Org and plan user with role :editor, but not :creator and :admin" do

      before do
        plan.add_user!(user.id, :editor)
      end

      it { is_expected.not_to include(plan) }

    end

    context "user belongs to Org and plan user with role :commenter, but not :creator and :admin" do

      before do
        plan.add_user!(user.id, :commenter)
      end

      it { is_expected.not_to include(plan) }

    end

    context "user belongs to Org and plan user with role :reviewer, but not :creator and :admin" do

      before do
        plan.add_user!(user.id, :reviewer)
      end

      it { is_expected.not_to include(plan) }

    end

  end

  context "#grant_api!" do

    let!(:org) { create(:org) }
    let(:token_permission_type) { create(:token_permission_type) }

    subject { org.grant_api!(token_permission_type) }

    context "when :token_permission_type does not belong to token_permission_types" do

      it { is_expected.to include(token_permission_type) }

    end

    context "when :token_permission_type belongs to token_permission_types" do

      before do

        org.token_permission_types << token_permission_type

      end

      it {
        is_expected.to be nil
        expect(org.token_permission_types).to include(token_permission_type)
      }

    end

  end

  describe "#links" do
    it "returns the contents of the field" do
      links = { "org": [{
        "link": Faker::Internet.url,
        "text": Faker::Lorem.word
      }] }
      org = build(:org, links: links)
      expect(org.links).to eql(JSON.parse(links.to_json))
    end
    it "defaults to {'org': }" do
      org = build(:org)
      expect(org.links).to eql(JSON.parse({ "org": [] }.to_json))
    end
  end

end
