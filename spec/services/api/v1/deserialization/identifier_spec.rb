# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::Deserialization::Identifier do

  before(:each) do
    @scheme = create(:identifier_scheme)
    @value = SecureRandom.uuid
    @class_name = "Org"
    @json = { type: @scheme.name, identifier: @value }
  end

  describe ":deserialize(class_name:, json: {})" do
    it "returns nil if :class_name is not present" do
      expect(described_class.deserialize(class_name: nil, json: @json)).to eql(nil)
    end
    it "returns nil if json is not valid" do
      expect(described_class.deserialize(class_name: @class_name, json: nil)).to eql(nil)
    end
    it "initializes a new Identifier when :type does not match an IdentifierScheme" do
      json = { type: "other", identifier: @value }
      rslt = described_class.deserialize(class_name: @class_name, json: json)
      expect(rslt.new_record?).to eql(true)
      validate_identifier(result: rslt, scheme: nil, value: @value)
    end
    it "does not load an existing Identifier when :type does not match an IdentifierScheme" do
      create(:identifier, identifier_scheme: nil, value: @value)
      json = { type: "other", identifier: @value }
      rslt = described_class.deserialize(class_name: @class_name, json: json)
      expect(rslt.new_record?).to eql(true)
      validate_identifier(result: rslt, scheme: nil, value: @value)
    end
    it "returns an existing Identifier when :type matches an IdentifierScheme" do
      id = create(:identifier, identifier_scheme: @scheme, value: @json[:identifier],
                               identifiable: create(:org))
      result = described_class.deserialize(class_name: @class_name, json: @json)
      expect(result).to eql(id)
    end
    it "initializes a new Identifier when :type matches an IdentifierScheme" do
      result = described_class.deserialize(class_name: @class_name, json: @json)
      expect(result.new_record?).to eql(true)
      validate_identifier(result: result, scheme: @scheme,
                          value: "#{@scheme.identifier_prefix}#{@json[:identifier]}")
    end
  end

  private

  def validate_identifier(result:, scheme:, value:)
    expect(result.is_a?(Identifier)).to eql(true), "expected it to be an Identifier"
    expect(result.identifier_scheme).to eql(scheme), "expected schemes to match"
    expect(result.value).to eql(value), "expected values to match"
  end

end
