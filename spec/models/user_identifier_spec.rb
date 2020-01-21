require 'rails_helper'

RSpec.describe UserIdentifier, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:identifier) }

    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:identifier_scheme) }

  end

  context "associations" do

    it { is_expected.to belong_to :user }

    it { is_expected.to belong_to :identifier_scheme }

  end

  context "scopes" do
    describe "#by_scheme_name" do
      before(:each) do
        user = create(:user)
        @scheme = create(:identifier_scheme, context: 0)
        @scheme2 = create(:identifier_scheme, context: 0)

        @id = create(:user_identifier, identifier_scheme: @scheme, user: user)
        @id2 = create(:user_identifier, identifier_scheme: @scheme2, user: user)

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

end
