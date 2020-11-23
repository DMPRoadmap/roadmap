# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ContextualErrorService do

  before(:each) do
    @plan = build(:plan)
    @plan.identifiers << build(:identifier)
    @plan.contributors << build(:contributor, org: build(:org), investigation: true)
    @plan.contributors.first.identifiers << build(:identifier)
    @plan.funder = build(:org)
    @plan.grant = build(:identifier)
  end

  describe "process_plan_errors(plan:)" do
    before(:each) do
      # invalidate everything
      @plan.title = nil
      @plan.identifiers.first.value = nil
      @plan.funder.name = nil
      @plan.grant.value = nil
      @plan.contributors.first.name = nil
      @plan.contributors.first.email = nil
      @plan.contributors.first.identifiers.first.value = nil
      @plan.contributors.first.org.name = nil
      @results = described_class.process_plan_errors(plan: @plan)
    end
    it "returns an empty array if :plan is not a Plan" do
      expect(described_class.process_plan_errors(plan: build(:org))).to eql([])
    end
    it "returns an empty array if :plan is valid" do
      expect(described_class.process_plan_errors(plan: build(:plan))).to eql([])
    end
    it "contextualizes the :plan errors" do
      expect(@results.include?("Dmp title can't be blank")).to eql(true)
    end
    it "contextualizes the :plan funder errors" do
      expect(@results.include?("Funding name can't be blank")).to eql(true)
    end
    it "contextualizes the :plan grant errors" do
      expect(@results.include?("Grant value can't be blank")).to eql(true)
    end
  end

  describe "contextualize(errors:)" do
    it "returns an empty array if :errors is an empty Array" do
      expect(described_class.contextualize(errors: [])).to eql([])
    end
    it "returns an empty array if :errors is an empty ActiveModel::Errors" do
      @plan.valid?
      expect(described_class.contextualize(errors: @plan.errors)).to eql([])
    end
    it "returns an empty array if :errors is not an Array or ActiveModel::Errors" do
      expect(described_class.contextualize(errors: build(:org))).to eql([])
    end
    it "defaults the :context to 'Dmp'" do
      result = described_class.contextualize(errors: ["Title can't be blank"])
      expect(result.first).to eql("Dmp title can't be blank")
    end
    it "swaps in the specified :context" do
      result = described_class.contextualize(errors: ["Title can't be blank"], context: "Foo")
      expect(result.first).to eql("Foo title can't be blank")
    end
    it "returns errors if the Plan is invalid" do
      @plan.title = nil
      @plan.valid?
      result = described_class.contextualize(errors: @plan.errors)
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Dmp title ")).to eql(true)
    end
    it "returns errors if the Plan Identifier is invalid" do
      @plan.identifiers.first.value = nil
      @plan.valid?
      result = described_class.contextualize(errors: @plan.errors)
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Dmp identifier ")).to eql(true)
    end
    it "returns errors if a Contributor is invalid" do
      @plan.contributors.first.name = nil
      @plan.contributors.first.email = nil
      @plan.valid?
      result = described_class.contextualize(errors: @plan.errors)
      expect(result.length).to eql(2)
      expect(result.first.start_with?("Contact/Contributor ")).to eql(true)
      expect(result.first.include?(" can't be blank if no ")).to eql(true)
    end
    it "returns errors if a Contributor Org is invalid" do
      @plan.contributors.first.org.name = nil
      @plan.valid?
      result = described_class.contextualize(errors: @plan.errors)
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Contact/Contributor affiliation ")).to eql(true)
    end
    it "returns errors if a Contributor Identifier is invalid" do
      @plan.contributors.first.identifiers.first.value = nil
      @plan.valid?
      result = described_class.contextualize(errors: @plan.errors)
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Contact/Contributor identifier ")).to eql(true)
    end
    it "returns errors if a Funder is invalid" do
      @plan.funder.name = nil
      @plan.funder.valid?
      result = described_class.contextualize(errors: @plan.funder.errors, context: "Funding")
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Funding name ")).to eql(true)
    end
    it "returns errors if a Grant is invalid" do
      @plan.grant.value = nil
      @plan.grant.valid?
      result = described_class.contextualize(errors: @plan.grant.errors, context: "Grant")
      expect(result.length).to eql(1)
      expect(result.first.start_with?("Grant value ")).to eql(true)
    end
  end

  describe "valid_plan?(plan:)" do
    it "returns false if :plan is not valid" do
      @plan.title = nil
      expect(described_class.valid_plan?(plan: @plan)).to eql(false)
    end
    it "returns false if :plan funder is not valid" do
      @plan.funder.name = nil
      expect(described_class.valid_plan?(plan: @plan)).to eql(false)
    end
    it "return false if :plan grant is not valid" do
      @plan.grant.value = nil
      expect(described_class.valid_plan?(plan: @plan)).to eql(false)
    end
    it "does not require :plan funder and grant to be present" do
      @plan.funder = nil
      @plan.grant = nil
      expect(described_class.valid_plan?(plan: @plan)).to eql(true)
    end
    it "returns true when everything is valid" do
      expect(described_class.valid_plan?(plan: @plan)).to eql(true)
    end
  end

end
