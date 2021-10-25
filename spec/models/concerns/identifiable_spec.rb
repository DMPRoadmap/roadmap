# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identifiable do

  # Using the Org model for testing this Concern
  before(:each) do
    @org = create(:org)
    @scheme1 = create(:identifier_scheme)
    @scheme2 = create(:identifier_scheme)
    @id1 = create(:identifier, identifier_scheme: @scheme1, identifiable: @org)
    @id2 = create(:identifier, identifier_scheme: @scheme2, identifiable: @org)
  end

  context "class methods" do

    describe "#from_identifiers(array:)" do
      it "returns nil if array is not present" do
        expect(Org.from_identifiers(array: nil)).to eql(nil)
      end
      it "returns nil if array is empty" do
        expect(Org.from_identifiers(array: [])).to eql(nil)
      end
      it "returns nil if the identifier scheme does not exist" do
        array = [{ name: SecureRandom.uuid, value: Faker::Lorem.word }]
        expect(Org.from_identifiers(array: array)).to eql(nil)
      end
      it "returns nil if no matches were found" do
        array = [{ name: @scheme1.name, value: SecureRandom.uuid }]
        expect(Org.from_identifiers(array: array)).to eql(nil)
      end
      it "returns the identifiable object" do
        array = [{ name: @scheme1.name, value: @id1.value }]
        expect(Org.from_identifiers(array: array)).to eql(@org)
      end
      it "does not return matching identifiable from another object" do
        array = [{ name: @scheme1.name, value: @id1.value }]
        expect(User.from_identifiers(array: array)).to eql(nil)
      end
      it "returns the first identifiable object if multiple matches" do
        array = [
          { name: @scheme2.name, value: @id2.value },
          { name: @scheme1.name, value: @id1.value }
        ]
        expect(Org.from_identifiers(array: array)).to eql(@org)
      end
    end

  end

  context "instance methods" do

    describe "#identifier_for_scheme(scheme:)" do
      it "returns nil if no identifier was found" do
        scheme3 = create(:identifier_scheme)
        expect(@org.identifier_for_scheme(scheme: scheme3)).to eql(nil)
      end
      it "returns nil if identifier scheme does not exist" do
        expect(@org.identifier_for_scheme(scheme: SecureRandom.uuid)).to eql(nil)
      end
      it "returns the identifier if passed the scheme name" do
        expect(@org.identifier_for_scheme(scheme: @scheme1.name)).to eql(@id1)
      end
      it "returns the identifier if passed the identifier scheme" do
        expect(@org.identifier_for_scheme(scheme: @scheme1)).to eql(@id1)
      end
    end

    describe "#consolidate_identifiers!(array:)" do
      it "returns the existing identifiers if array is not present" do
        expect(@org.consolidate_identifiers!(array: nil)).to eql(false)
      end
      it "returns the existing identifiers if array is empty" do
        expect(@org.consolidate_identifiers!(array: [])).to eql(false)
      end
      it "ignores items in array if they are not identifiers" do
        array = [build(:org)]
        original = @org.identifiers
        @org.consolidate_identifiers!(array: array)
        expect(@org.identifiers).to eql(original)
      end
      it "does not replace an existing identifier" do
        array = [build(:identifier, identifier_scheme: @scheme1, value: "Foo")]
        @org.consolidate_identifiers!(array: array)
        expect(@org.identifier_for_scheme(scheme: @scheme1).value).to eql(@id1.value)
      end
      it "adds the new identifier" do
        scheme3 = create(:identifier_scheme)
        array = [build(:identifier, identifier_scheme: scheme3, value: "Foo")]
        @org.consolidate_identifiers!(array: array)
        expected = @org.identifier_for_scheme(scheme: scheme3).value
        expect(expected.ends_with?("Foo")).to eql(true)
      end
    end

  end

end
