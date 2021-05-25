# frozen_string_literal: true

require "rails_helper"

describe Subscription do

  context "associations" do
    it { is_expected.to belong_to :plan }
    it { is_expected.to belong_to :subscriber }
  end

  context "instance methods" do
    describe "#notify!" do
      before(:each) do
        @subscription = build(:subscription, :for_updates, plan: create(:plan), subscriber: build(:api_client))
      end
      it "does not notify the subscriber if :last_notified > plan.updated_at" do
        @subscription.last_notified = Time.now + 1.days
        expect(@subscription.notify!).to eql(false)
      end
      it "updates :last_notified" do
        original = @subscription.last_notified
        @subscription.notify!
        expect(@subscription.last_notified > original).to eql(true)
      end
      it "notifies the subscriber" do
        expect(@subscription.notify!).to eql(true)
      end
    end
  end
end
