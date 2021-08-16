# frozen_string_literal: true

require "rails_helper"

RSpec.describe Subscribable do

  # Using the Plan model for testing this Concern
  before(:each) do
    @plan = create(:plan)

    @api_client = create(:api_client)
    @scheme = create(:identifier_scheme, name: @api_client.name, for_plans: true)

    @subscription = create(:subscription, subscriber: @api_client, plan: @plan,
                                          subscription_types: "updates")
    @api_client.reload
  end

  context "associations" do
    it { expect(@api_client.respond_to?(:subscriptions)).to eql(true) }
  end

  context "instance methods" do
    describe ":subscriptions_for(plan:)" do
      it "returns an empty array if plan is not present" do
        expect(@api_client.subscriptions_for(plan: nil)).to eql([])
      end
      it "returns an empty array if the api_climet has no subscription for the plan" do
        Subscription.all.destroy_all
        expect(@api_client.subscriptions_for(plan: @plan)).to eql([])
      end
      it "returns the subscription for the specified plan" do
        results = @api_client.subscriptions_for(plan: @plan)
        expect(results.length).to eql(1)
        expect(results.first).to eql(@subscription)
      end
    end
  end
end
