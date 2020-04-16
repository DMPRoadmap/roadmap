# frozen_string_literal: true

require "rails_helper"

RSpec.describe Org, type: :model do

  context "instance methods" do
    before(:each) do
      plan = create(:plan)
      @owner = create(:user)
      plan.roles << create(:role, :creator, user: @owner)
      @exported = build(:exported_plan, plan: plan)
    end

    describe "#orcid" do
      it "returns an empty string if the owner is nil" do
        @exported.user = nil
        expect(@exported.orcid).to eql("")
      end
      it "returns an empty string if the owner has no ORCID identifier" do

        expect(@exported.orcid).to eql("")
      end
      it "returns the ORCID identifier" do
        scheme = build(:identifier_scheme, name: "orcid")
        identifier = build(:identifier, :for_user, identifier_scheme: scheme)
        @exported.owner.identifiers << identifier
        expect(@exported.orcid).to eql(identifier.value)
      end
    end

  end

end
