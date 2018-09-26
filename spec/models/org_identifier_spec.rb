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
