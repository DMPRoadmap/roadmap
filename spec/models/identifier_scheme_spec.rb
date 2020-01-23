require 'rails_helper'

RSpec.describe IdentifierScheme, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(30) }

    it { is_expected.to allow_value(true).for(:name) }

    it { is_expected.to allow_value(false).for(:name) }

    it { is_expected.to_not allow_value(nil).for(:name) }
  end

  context "associations" do
    it { is_expected.to have_many :identifiers }
  end

  context "scopes" do
    before(:each) do
      @scheme = create(:identifier_scheme)
    end

    describe "#by_name scope" do
     it "is case insensitive" do
       rslt = described_class.by_name(@scheme.name.upcase).first
       expect(rslt).to eql(@scheme)
     end

      it "returns the IdentifierScheme" do
       rslt = described_class.by_name(@scheme.name).first
       expect(rslt).to eql(@scheme)
     end

      it "returns empty ActiveRecord results if nothing is found" do
       rslts = described_class.by_name(Faker::Lorem.sentence)
       expect(rslts.empty?).to eql(true)
     end
   end
  end

end
