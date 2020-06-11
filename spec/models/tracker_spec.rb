# frozen_string_literal: true
#
require 'rails_helper'

RSpec.describe Tracker, type: :model do
  describe "creation" do
    it "can be created from an org" do
      org = build(:org)
      tracker = org.build_tracker
      expect(tracker).to be_valid
    end

    it "can be created with an empty code" do
      org = build(:org)
      tracker = org.build_tracker(code:  "")
      expect(tracker).to be_valid
    end

    it "fails with a badly formatted code" do
      org = build(:org)
      tracker = org.build_tracker(code: "XXXXXXXXXX")
      expect(tracker).to_not be_valid
    end

    it "works with a valid code" do
      org = build(:org)
      tracker = org.build_tracker(code: "UA-12345678-12")
      expect(tracker).to be_valid
    end

    it "fails with a null org" do
      org = build(:org)
      tracker = org.build_tracker(code: "XXXXXXXXXX")
      tracker.org = nil
      expect(tracker).to_not be_valid
    end
  end
end
