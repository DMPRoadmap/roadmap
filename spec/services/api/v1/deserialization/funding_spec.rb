# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Funding do

  before(:each) do
    # Org requires a language, so make sure a default is available!
    create(:language, default_language: true) unless Language.default

    @funder = create(:org, :funder, name: Faker::Company.name)
    @plan = create(:plan)
    @grant = create(:identifier, identifier_scheme: nil, value: SecureRandom.uuid,
                                 identifiable: @plan)

    Api::V1::Deserialization::Org.stubs(:deserialize!).returns(@funder)
    Api::V1::Deserialization::Identifier.stubs(:deserialize!).returns(@grant)

    @json = {
      name: @funder.name,
      funding_status: %w[planned granted rejected].sample
    }
  end

  describe "#deserialize!(plan:, json: {})" do
    it "returns nil if plan is not present" do
      expect(described_class.deserialize!(plan: nil, json: @json)).to eql(nil)
    end
    it "returns the Plan as-is if json is present" do
      expect(described_class.deserialize!(plan: @plan, json: nil)).to eql(@plan)
    end
    it "returns the Plan as-is if json is not valid" do
      json = { funding_status: "planned" }
      expect(described_class.deserialize!(plan: @plan, json: json)).to eql(@plan)
    end
    it "assigns the funder" do
      result = described_class.deserialize!(plan: @plan, json: @json)
      expect(result.funder).to eql(@funder)
    end
    it "assigns the grant" do
      json = @json.merge({ grant_id: { type: "url", identifier: Faker::Lorem.word } })
      result = described_class.deserialize!(plan: @plan, json: json)
      expect(result.grant_id).to eql(@grant.id)
    end
    it "returns the Plan" do
      expect(described_class.deserialize!(plan: @plan, json: @json)).to eql(@plan)
    end
  end

  context "private methods" do

    describe "#valid?(json:)" do
      it "returns false if json is not present" do
        expect(described_class.send(:valid?, json: nil)).to eql(false)
      end
      it "returns false if :name and :funder_id and :grant_id are not present" do
        json = { funding_status: %w[] }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it "returns true if :name is present" do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
      it "returns true if :funder_id is present" do
        json = {
          funder_id: { type: Faker::Lorem.word, identifier: SecureRandom.uuid }
        }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
      it "returns true if :grant_id is present" do
        json = { grant_id: { type: Faker::Lorem.word, identifier: @grant.value } }
        expect(described_class.send(:valid?, json: json)).to eql(true)
      end
    end

    describe "#deserialize_grant(plan:, json:)" do
      it "returns the Plan as-is if no json is present" do
        result = described_class.send(:deserialize_grant, plan: @plan, json: nil)
        expect(result).to eql(@plan)
      end
      it "returns the Plan as-is if no :grant_id is present" do
        result = described_class.send(:deserialize_grant, plan: @plan, json: @json)
        expect(result).to eql(@plan)
      end
      it "attaches the the grant to the plan" do
        json = @json.merge(
          { grant_id: { type: "url", identifier: @grant.value } }
        )
        result = described_class.send(:deserialize_grant, plan: @plan, json: json)
        expect(result.grant_id.present?).to eql(true)
        expect(result.grant.identifier_scheme).to eql(nil)
        expect(result.grant.value).to eql(json[:grant_id][:identifier])
      end
    end

  end

end
