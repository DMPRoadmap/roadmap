require 'rails_helper'

RSpec.describe IdentifierScheme, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(30) }

    it { is_expected.to allow_value(true).for(:name) }

    it { is_expected.to allow_value(false).for(:name) }

    it { is_expected.to_not allow_value(nil).for(:name) }

    it { is_expected.to validate_presence_of(:context) }

    it { is_expected.to allow_values(0, 1).for(:context) }

  end

  context "associations" do

    it { is_expected.to have_many :user_identifiers }

    it { is_expected.to have_many(:users).through(:user_identifiers) }

  end

  context "scopes" do
    before(:each) do
      @user_scheme = create(:identifier_scheme, context: :user)
      @org_scheme = create(:identifier_scheme, context: :org)
    end

    describe "#user_schemes" do
      it "returns only the schemes with a context of :user" do
        rslts = described_class.user_schemes
        expect(rslts.include?(@user_scheme)).to eql(true)
        expect(rslts.include?(@org_scheme)).to eql(false)
      end
    end

    describe "#org_schemes" do
      it "returns only the schemes with a context of :org" do
        rslts = described_class.org_schemes
        expect(rslts.include?(@user_scheme)).to eql(false)
        expect(rslts.include?(@org_scheme)).to eql(true)
      end
    end

    describe "#by_name scope" do
      it "is case insensitive" do
        rslt = described_class.by_name(@user_scheme.name.upcase).first
        expect(rslt).to eql(@user_scheme)
      end

      it "returns the IdentifierScheme" do
        rslt = described_class.by_name(@user_scheme.name).first
        expect(rslt).to eql(@user_scheme)
      end

      it "returns empty ActiveRecord results if nothing is found" do
        rslts = described_class.by_name(Faker::Lorem.sentence)
        expect(rslts.empty?).to eql(true)
      end
    end
  end
end
