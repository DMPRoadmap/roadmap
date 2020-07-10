# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identifier, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:value) }

    it { is_expected.to validate_presence_of(:identifiable) }

    describe "uniqueness" do
      before(:each) do
        @org = create(:org)
      end

      it "prevents duplicate value when identifier_scheme is nil" do
        create(:identifier_scheme)
        create(:identifier, identifiable: @org, identifier_scheme: nil,
                            value: "foo")
        id = build(:identifier, identifiable: @org, identifier_scheme: nil,
                                value: "foo")
        expect(id.valid?).to eql(false)
        expect(id.errors[:value].present?).to eql(true)
      end
      it "allows a duplicate value for the identifier_scheme" do
        scheme = create(:identifier_scheme)
        create(:identifier, identifiable: @org, identifier_scheme: scheme,
                            value: "foo")
        id = build(:identifier, identifiable: create(:org),
                                identifier_scheme: scheme, value: "foo")
        expect(id.valid?).to eql(true)
      end
      it "prevents multiple identifiers per identifier_scheme" do
        scheme = create(:identifier_scheme)
        create(:identifier, identifiable: @org, identifier_scheme: scheme,
                            value: Faker::Lorem.word)
        id = build(:identifier, identifiable: @org, identifier_scheme: scheme,
                                value: Faker::Number.number.to_s)
        expect(id.valid?).to eql(false)
        expect(id.errors[:identifier_scheme].present?).to eql(true)
      end
      it "does not apply if the value is unique and identifier_scheme is nil" do
        create(:identifier, identifiable: @org, identifier_scheme: nil,
                            value: Faker::Lorem.word)
        id = build(:identifier, identifiable: @org, identifier_scheme: nil,
                                value: Faker::Number.number.to_s)
        expect(id.valid?).to eql(true)
      end
      it "does not prevent identifiers for same scheme but different identifiables" do
        scheme = create(:identifier_scheme)
        create(:identifier, identifiable: @org, identifier_scheme: scheme,
                            value: Faker::Lorem.word)
        id = build(:identifier, identifiable: create(:org),
                                identifier_scheme: scheme,
                                value: Faker::Number.number.to_s)
        expect(id.valid?).to eql(true)
      end
      it "does not prevent same value for different schemes and identifiables" do
        scheme = create(:identifier_scheme)
        create(:identifier, identifiable: @org, identifier_scheme: scheme,
                            value: "foo")
        id = build(:identifier, identifiable: create(:org),
                                identifier_scheme: create(:identifier_scheme),
                                value: "foo")
        expect(id.valid?).to eql(true)
      end
    end
  end

  context "associations" do
    it { is_expected.to belong_to(:identifiable) }

    it { is_expected.to belong_to(:identifier_scheme).optional }
  end

  context "scopes" do
    describe "#by_scheme_name" do
      before(:each) do
        @scheme = create(:identifier_scheme)
        @scheme2 = create(:identifier_scheme)
        @id = create(:identifier, :for_plan, identifier_scheme: @scheme)
        @id2 = create(:identifier, :for_plan, identifier_scheme: @scheme2)

        @rslts = described_class.by_scheme_name(@scheme.name, "Plan")
      end

      it "returns the correct identifier" do
        expect(@rslts.include?(@id)).to eql(true)
      end
      it "does not return the identifier for the other scheme" do
        expect(@rslts.include?(@id2)).to eql(false)
      end
    end
  end

  describe "#attrs=" do
    let!(:identifier) { create(:identifier) }

    it "when hash is a Hash sets attrs to a String of JSON" do
      identifier.attrs = { foo: "bar" }
      expect(identifier.attrs).to eql({ "foo": "bar" }.to_json)
    end

    it "when hash is nil sets attrs to empty JSON object" do
      identifier.attrs = nil
      expect(identifier.attrs).to eql({}.to_json)
    end

    it "when hash is a String sets attrs to empty JSON object" do
      identifier.attrs = ""
      expect(identifier.attrs).to eql({}.to_json)
    end
  end

  describe "#identifier_format" do
    it "returns 'orcid' for identifiers associated with the orcid identifier_scheme" do
      scheme = build(:identifier_scheme, name: "orcid")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("orcid")
    end
    it "returns 'ror' for identifiers associated with the ror identifier_scheme" do
      scheme = build(:identifier_scheme, name: "ror")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("ror")
    end
    it "returns 'fundref' for identifiers associated with the fundref identifier_scheme" do
      scheme = build(:identifier_scheme, name: "fundref")
      id = build(:identifier, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("fundref")
    end
    it "returns 'ark' for identifiers whose value contains 'ark:'" do
      scheme = build(:identifier_scheme, name: "ror")
      val = "#{scheme.identifier_prefix}ark:#{Faker::Lorem.word}"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("ark")
    end
    it "returns 'doi' for identifiers whose value matches the doi format" do
      scheme = build(:identifier_scheme, name: "ror")
      val = "#{scheme.identifier_prefix}doi:10.1234/123abc98"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("doi"), "expected url containing 'doi:' to be a doi"

      val = "#{scheme.identifier_prefix}10.1234/123abc98"
      id = create(:identifier, value: val)
      expect(id.identifier_format).to eql("doi"), "expected url not containing 'doi:' to be a doi"
    end
    it "returns 'url' for identifiers whose value matches a URL format" do
      scheme = build(:identifier_scheme, name: "ror")
      id = create(:identifier, value: "#{scheme.identifier_prefix}#{Faker::Lorem.word}")
      expect(id.identifier_format).to eql("url")

      id = create(:identifier, value: "#{scheme.identifier_prefix}#{Faker::Lorem.word}")
      expect(id.identifier_format).to eql("url")
    end
    it "returns 'other' for all other identifier values" do
      scheme = build(:identifier_scheme, identifier_prefix: nil)
      id = create(:identifier, value: Faker::Lorem.word, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("other"), "expected alpha characters to return 'other'"

      id = create(:identifier, value: Faker::Number.number, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("other"), "expected numeric characters to return 'other'"

      id = create(:identifier, value: SecureRandom.uuid, identifier_scheme: scheme)
      expect(id.identifier_format).to eql("other"), "expected UUID to return 'other'"
    end
  end

  describe "#value_without_scheme_prefix" do
    before(:each) do
      @scheme = create(:identifier_scheme, identifier_prefix: Faker::Internet.url)
      @without = Faker::Lorem.word
      @val = "#{@scheme.identifier_prefix}/#{@without}"
    end

    it "returns the value as is if no identifier scheme is present" do
      id = create(:identifier, value: @val, identifier_scheme: nil)
      expect(id.value_without_scheme_prefix).to eql(@val)
    end
    it "returns the value as is if no identifier scheme has no prefix" do
      @scheme.identifier_prefix = nil
      id = create(:identifier, value: @val, identifier_scheme: @scheme)
      expect(id.value_without_scheme_prefix).to eql(@val)
    end
    it "returns the value without the identifier scheme prefix" do
      id = create(:identifier, value: @val, identifier_scheme: @scheme)
      expect(id.value_without_scheme_prefix).to eql(@without)
    end
  end

  describe "#value=(val)" do
    before(:each) do
      @scheme = create(:identifier_scheme, identifier_prefix: Faker::Internet.url)
    end

    it "returns the value if the identifier_scheme is not present" do
      val = Faker::Lorem.word
      id = build(:identifier, value: val, identifier_scheme: nil)
      expect(id.value).to eql(val)
    end
    it "returns the value if the identifier_scheme has no prefix" do
      val = Faker::Lorem.word
      @scheme.identifier_prefix = nil
      id = build(:identifier, value: val, identifier_scheme: @scheme)
      expect(id.value).to eql(val)
    end
    it "returns the value if the value is already a URL" do
      val = "#{@scheme.identifier_prefix}/#{Faker::Lorem.word}"
      id = build(:identifier, value: val, identifier_scheme: @scheme)
      expect(id.value).to eql(val)
    end
    it "appends the identifier scheme prefix to the value" do
      val = Faker::Lorem.word
      id = build(:identifier, value: val, identifier_scheme: @scheme)
      expected = @scheme.identifier_prefix
      expect(id.value.starts_with?(expected)).to eql(true)
    end
    it "appends the identifier scheme prefix to the value even if its a URL" do
      val = Faker::Internet.url
      id = build(:identifier, value: val, identifier_scheme: @scheme)
      expected = @scheme.identifier_prefix
      expect(id.value.starts_with?(expected)).to eql(true)
    end
  end

end
