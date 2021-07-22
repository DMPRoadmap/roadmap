# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::PersistenceService do

  describe "safe_save(plan:)" do
    it "returns nil if :plan is not a Plan" do
      expect(described_class.safe_save(plan: build(:org))).to eql(nil)
    end
    it "returns nil if :plan is not valid?" do
      expect(described_class.safe_save(plan: build(:plan, title: nil))).to eql(nil)
    end
    it "saves the :plan that has no other associations" do
      plan = build(:plan)
      result = described_class.safe_save(plan: plan)
      expect(result.new_record?).to eql(false)
      expect(result.title).to eql(plan.title)
    end
    it "saves the :plan that has contributors" do
      plan = build(:plan)
      contributor = build(:contributor, investigation: true)
      plan.contributors << contributor
      result = described_class.safe_save(plan: plan)
      expect(result.contributors.length).to eql(1)
      expect(result.contributors.first.new_record?).to eql(false)
      expect(result.contributors.first.email).to eql(contributor.email)
    end
    it "safely handles duplicate contributors" do
      plan = build(:plan)
      contributor = build(:contributor, investigation: true)
      plan.contributors << contributor
      plan.contributors << contributor.clone
      result = described_class.safe_save(plan: plan)
      expect(result.contributors.length).to eql(1)
      expect(result.contributors.first.new_record?).to eql(false)
      expect(result.contributors.first.email).to eql(contributor.email)
    end
    it "safely handles duplicate orgs" do
      plan = build(:plan)
      org = build(:org)
      contributor = build(:contributor, investigation: true, org: org)
      contributor2 = build(:contributor, investigation: true, org: org)
      plan.contributors << contributor
      plan.contributors << contributor2
      result = described_class.safe_save(plan: plan)
      expect(result.contributors.length).to eql(2)
      expect(result.contributors.first.org).to eql(result.contributors.last.org)
    end
    it "saves the :plan that has identifiers" do
      plan = build(:plan)
      id = build(:identifier)
      plan.identifiers << id
      result = described_class.safe_save(plan: plan)
      expect(result.identifiers.length).to eql(1)
      expect(result.identifiers.first.new_record?).to eql(false)
      expect(result.identifiers.first.value).to eql(id.value)
    end
    it "saves the :plan that has a funder" do
      plan = build(:plan)
      org = build(:org)
      plan.funder = org
      result = described_class.safe_save(plan: plan)
      expect(result.funder.present?).to eql(true)
      expect(result.funder.name).to eql(org.name)
    end
    it "saves the :plan that has a grant" do
      plan = build(:plan)
      id = build(:identifier)
      plan.grant = id
      result = described_class.safe_save(plan: plan)
      expect(result.grant.present?).to eql(true)
      expect(result.grant.value).to eql(id.value)
    end
  end

  context "private methods" do
    describe "safe_save_identifier(identifier:)" do
      before(:each) do
        @org = create(:org)
      end

      it "returns nil unless :identifier is an Identifier" do
        expect(described_class.send(:safe_save_identifier, identifier: build(:org))).to eql(nil)
      end
      it "returns nil and does not save the :identifier if it is not valid" do
        id = build(:identifier, identifiable: @org, value: nil)
        expect(described_class.send(:safe_save_identifier, identifier: id)).to eql(nil)
      end
      it "loads the Identifier if the :identifier is not valid because it already exists" do
        existing = create(:identifier, identifiable: @org)
        id = build(:identifier, value: existing.value, identifiable: @org,
                                identifier_scheme: existing.identifier_scheme)
        expect(described_class.send(:safe_save_identifier, identifier: id)).to eql(existing)
      end
      it "creates the identifier" do
        id = build(:identifier, identifiable: @org)
        result = described_class.send(:safe_save_identifier, identifier: id)
        expect(result.new_record?).to eql(false)
        expect(result.value).to eql(id.value)
      end
    end

    describe "safe_save_org(org:)" do
      it "returns nil unless :org is an Org" do
        expect(described_class.send(:safe_save_org, org: build(:identifier))).to eql(nil)
      end
      it "returns nil and does not save the :org if it is not valid" do
        org = build(:org, name: nil)
        expect(described_class.send(:safe_save_org, org: org)).to eql(nil)
      end
      it "loads the Org if the :org already exists" do
        existing = create(:org)
        org = build(:org, name: existing.name)
        expect(described_class.send(:safe_save_org, org: org)).to eql(existing)
      end
      it "creates the Org" do
        org = build(:org)
        result = described_class.send(:safe_save_org, org: org)
        expect(result.new_record?).to eql(false)
        expect(result.name).to eql(org.name)
        expect(result.abbreviation).to eql(org.abbreviation)
      end
      it "also creates any identifiers for the Org" do
        org = build(:org)
        id = build(:identifier)
        org.identifiers << id
        result = described_class.send(:safe_save_org, org: org)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.first.value).to eql(id.value)
      end
    end

    describe "safe_save_contributor(contributor:)" do
      it "returns nil unless :contributor is an Contributor" do
        expect(described_class.send(:safe_save_contributor, contributor: build(:org))).to eql(nil)
      end
      it "returns nil and does not save the :contributor if it is not valid" do
        contributor = build(:contributor, plan: create(:plan), email: nil)
        expect(described_class.send(:safe_save_contributor, contributor: contributor)).to eql(nil)
      end
      it "loads the Contributor if the :contributor already exists" do
        existing = create(:contributor, plan: create(:plan), investigation: true)
        contributor = build(:contributor, email: existing.email, investigation: true)
        result = described_class.send(:safe_save_contributor, contributor: contributor)
        expect(result).to eql(existing)
      end
      it "creates the Contributor" do
        contributor = build(:contributor, plan: create(:plan), investigation: true)
        result = described_class.send(:safe_save_contributor, contributor: contributor)
        expect(result.new_record?).to eql(false)
        expect(result.email).to eql(contributor.email)
        expect(result.name).to eql(contributor.name)
      end
      it "also creates the Org for the Contributor" do
        contributor = build(:contributor, org: build(:org), plan: create(:plan),
                                          investigation: true)
        result = described_class.send(:safe_save_contributor, contributor: contributor)
        expect(result.org.name).to eql(contributor.org.name)
      end
      it "also creates any identifiers for the Contributor" do
        contributor = build(:contributor, plan: create(:plan), investigation: true)
        id = build(:identifier)
        contributor.identifiers << id
        result = described_class.send(:safe_save_contributor, contributor: contributor)
        expect(result.identifiers.length).to eql(1)
        expect(result.identifiers.first.value).to eql(id.value)
      end
    end

    describe "deduplicate_contributors(contributors:)" do
      before(:each) do
        scheme = create(:identifier_scheme, name: "orcid")
        @plan = build(:plan)
        @orcid = build(:identifier, identifier_scheme: scheme)
        @contributor = build(:contributor, investigation: true, identifiers: [@orcid])
        @plan.contributors << @contributor
      end
      it "returns an empty array unless the :contributors is an Array" do
        expect(described_class.send(:deduplicate_contributors, contributors: nil)).to eql([])
      end
      it "returns an empty array if :contributors is empty" do
        @plan.contributors = []
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(0)
      end
      it "leaves different :contributors as-is" do
        @plan.contributors << build(:contributor, name: Faker::Movies::StarWars.character,
                                                  email: Faker::Internet.unique.email)
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(2)
      end
      it "consolidates :contributors with the same email" do
        @plan.contributors << build(:contributor, email: @contributor.email)
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(1)
      end
      it "consolidates :contributors with the same ORCID" do
        @plan.contributors << build(:contributor, identifiers: [@orcid])
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(1)
      end
      it "consolidates :contributors with the same name" do
        @plan.contributors << build(:contributor, name: @contributor.name)
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(1)
      end
      it "consolidates the Contributor's Org" do
        @plan.contributors.first.org = nil
        new_contributor = build(:contributor, email: @contributor.email, org: build(:org))
        @plan.contributors << new_contributor
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(1)
        expect(results.first.org).to eql(new_contributor.org)
      end
      it "consolidates the Contributor's ORCID" do
        @plan.contributors.first.identifiers = []
        new_contributor = build(:contributor, email: @contributor.email, identifiers: [@orcid])
        @plan.contributors << new_contributor
        results = described_class.send(:deduplicate_contributors, contributors: @plan.contributors)
        expect(results.length).to eql(1)
        expect(results.first.identifiers.first).to eql(new_contributor.identifiers.first)
      end
    end
  end
end
