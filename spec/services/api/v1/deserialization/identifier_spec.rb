# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Identifier do

  before(:each) do
    @scheme = create(:identifier_scheme)
    @value = SecureRandom.uuid
    @identifiable = build(:org)
    @json = { type: @scheme.name, identifier: @value }
  end

  describe "#deserialize!(identifiable:, json: {})" do
    it "returns nil if json is not valid" do
      result = described_class.deserialize!(identifiable: @identifiable,
                                            json: nil)
      expect(result).to eql(nil)
    end

    context "when :type does not match an IdentifierScheme" do

      it "marshalls an Identifier" do
        json = { type: "other", identifier: @value }
        rslt = described_class.deserialize!(identifiable: @identifiable, json: json)
        validate_identifier(result: rslt, scheme: nil, value: @value)
      end
      it "marshalls an existing Identifier" do
        id = create(:identifier, identifier_scheme: nil,
                                 identifiable: @identifiable, value: @value)
        json = { type: "other", identifier: @value }
        rslt = described_class.deserialize!(identifiable: @identifiable, json: json)
        validate_identifier(result: rslt, scheme: nil, value: @value)
        expect(rslt.id).to eql id.id
      end

    end

    context "when :type matches an IdentifierScheme" do
      it "calls #identifier_for_scheme" do
        described_class.expects(:identifier_for_scheme).at_least(1)
        described_class.deserialize!(identifiable: @identifiable, json: @json)
      end
      it "returns an Identifier for that IdentifierScheme" do
        result = described_class.deserialize!(identifiable: @identifiable,
                                              json: @json)
        expect(result.identifier_scheme).to eql(@scheme)
      end

    end

  end

  context "private methods" do

    describe "#valid?(json:)" do
      it "returns nil if json is not valid" do
        expect(described_class.send(:valid?, json: nil)).to eql(false)
      end
      it "returns nil if :identifier is not present" do
        json = { type: @scheme.name }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it "returns nil if :type is not present" do
        json = { identifier: @value }
        expect(described_class.send(:valid?, json: json)).to eql(false)
      end
      it "returns true" do
        expect(described_class.send(:valid?, json: @json)).to eql(true)
      end
    end

    describe "#identifier_for_scheme(scheme:, identifiable:, json:)" do
      it "returns nil if scheme is nil" do
        result = described_class.send(:identifier_for_scheme,
                                      scheme: nil, identifiable: @identifiable,
                                      json: @json)
        expect(result).to eql(nil)
      end
      it "returns nil if identifiable is nil" do
        result = described_class.send(:identifier_for_scheme,
                                      scheme: @scheme, identifiable: nil,
                                      json: @json)
        expect(result).to eql(nil)
      end
      it "returns nil if json is nil" do
        result = described_class.send(:identifier_for_scheme,
                                      scheme: @scheme, identifiable: @identifiable,
                                      json: nil)
        expect(result).to eql(nil)
      end
      it "returns nil if :type does not match an IdentifierScheme" do
        json = { type: Faker::Lorem.word, identifier: @value }
        result = described_class.send(:identifier_for_scheme,
                                      scheme: @scheme,
                                      identifiable: @identifiable, json: json)
        expect(result).to eql(nil)
      end
      it "returns the updated Identifier for the IdentifierScheme" do
        identifier = create(:identifier, identifier_scheme: @scheme,
                                         identifiable: @identifiable,
                                         value: Faker::Number.number)
        result = described_class.send(:identifier_for_scheme,
                                      scheme: @scheme,
                                      identifiable: @identifiable, json: @json)
        expected = "#{@scheme.identifier_prefix}#{@json[:identifier]}"
        validate_identifier(result: result, scheme: @scheme, value: expected)
        expect(result.id).to eql(identifier.id)
      end
    end

  end

  private

  def validate_identifier(result:, scheme:, value:)
    expect(result.is_a?(Identifier)).to eql(true), "expected it to be an Identifier"
    expect(result.identifier_scheme).to eql(scheme), "expected schemes to match"
    expect(result.value).to eql(value), "expected values to match"
  end

end
