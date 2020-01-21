require 'rails_helper'

RSpec.describe OrgIdentifier, type: :model do

  context "validations" do

    it do
      # https://github.com/thoughtbot/shoulda-matchers/issues/682
      subject.identifier_scheme = create(:identifier_scheme)
      is_expected.to validate_uniqueness_of(:identifier_scheme_id)
                       .scoped_to(:org_id)
                       .with_message("must be unique")
    end

    it { is_expected.to validate_presence_of(:identifier) }

    it { is_expected.to validate_presence_of(:org) }

    it { is_expected.to validate_presence_of(:identifier_scheme) }

  end

  context "associations" do

    it { is_expected.to belong_to(:org) }

    it { is_expected.to belong_to(:identifier_scheme) }

  end

  context "scopes" do
    describe "#by_scheme_name" do
      before(:each) do
        org = create(:org, is_other: false)
        @scheme = create(:identifier_scheme, context: 0)
        @scheme2 = create(:identifier_scheme, context: 0)

        @id = create(:org_identifier, identifier_scheme: @scheme, org: org)
        @id2 = create(:org_identifier, identifier_scheme: @scheme2, org: org)

        @rslts = described_class.by_scheme_name(@scheme.name)
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

    context "when hash is a Hash" do

      let!(:org_identifier) { create(:org_identifier) }

      it "sets attrs to a String of JSON" do
        org_identifier.attrs = { foo: "bar" }
        expect(org_identifier.attrs).to eql({"foo" => "bar"}.to_json)
      end

    end

    context "when hash is nil" do

      let!(:org_identifier) { create(:org_identifier) }

      it "sets attrs to empty JSON object" do
        org_identifier.attrs = nil
        expect(org_identifier.attrs).to eql({}.to_json)
      end

    end

    context "when hash is a String" do

      let!(:org_identifier) { create(:org_identifier) }

      it "sets attrs to empty JSON object" do
        org_identifier.attrs = ''
        expect(org_identifier.attrs).to eql({}.to_json)
      end

    end

  end

end
