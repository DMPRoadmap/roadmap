# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ConversionService do

  describe "boolean_to_yes_no_unknown" do
    it "returns `yes` when true" do
      expect(described_class.boolean_to_yes_no_unknown(true)).to eql("yes")
    end
    it "returns `yes` when 1" do
      expect(described_class.boolean_to_yes_no_unknown(1)).to eql("yes")
    end
    it "returns `no` when false" do
      expect(described_class.boolean_to_yes_no_unknown(false)).to eql("no")
    end
    it "returns `no` when 0" do
      expect(described_class.boolean_to_yes_no_unknown(0)).to eql("no")
    end
    it "returns `unknown` when nil" do
      expect(described_class.boolean_to_yes_no_unknown(nil)).to eql("unknown")
    end
  end

  describe "yes_no_unknown_to_boolean" do
    it "returns true when `yes`" do
      expect(described_class.yes_no_unknown_to_boolean("yes")).to eql(true)
    end
    it "returns false when `no`" do
      expect(described_class.yes_no_unknown_to_boolean("no")).to eql(false)
    end
    it "returns nil when `unknown`" do
      expect(described_class.yes_no_unknown_to_boolean("unknown")).to eql(nil)
    end
  end

  describe "#to_identifier(context:, value:)" do
    it "returns nil if the context is not present" do
      expected = described_class.to_identifier(context: nil,
                                               value: Faker::Lorem.word)
      expect(expected).to eql(nil)
    end
    it "returns nil if the value is not present" do
      expected = described_class.to_identifier(context: Faker::Lorem.word,
                                               value: nil)
      expect(expected).to eql(nil)
    end
    it "returns an Identifier with a IdentifierScheme matching the context" do
      context = Faker::Lorem.word
      expected = described_class.to_identifier(context: context,
                                               value: Faker::Lorem.word)
      expect(expected.identifier_scheme.name).to eql(context)
    end
    it "returns an Identifier asssociated with the 'grant' scheme" do
      value = Faker::Lorem.word
      expected = described_class.to_identifier(context: Faker::Lorem.word,
                                               value: value)
      expect(expected.value).to eql(value)
    end
  end

end
