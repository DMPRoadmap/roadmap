# frozen_string_literal: true

require "rails_helper"

RSpec.describe Identifier, type: :model do

  context "validations" do
    it do
      subject.identifier_scheme = create(:identifier_scheme)
      subject.value = Faker::Lorem.word
      is_expected.to validate_uniqueness_of(:identifier_scheme)
        .scoped_to(%i[identifiable_id identifiable_type])
        .with_message("must be unique")
    end

    it { is_expected.to validate_presence_of(:value) }

    it { is_expected.to validate_presence_of(:identifiable) }

    it { is_expected.to validate_presence_of(:identifier_scheme) }
  end

  context "associations" do
    it { is_expected.to belong_to(:identifiable) }

    it { is_expected.to belong_to(:identifier_scheme) }
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

end
