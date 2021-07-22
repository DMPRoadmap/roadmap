# frozen_string_literal: true

require "rails_helper"

UUID_REGEX ||= /\A[\w\d]{8}(-[\w\d]{4}){3}-[\w\d]{12}\Z/i.freeze

shared_examples_for "VersionableModel" do

  context "attributes" do

    it { is_expected.to have_readonly_attribute(:versionable_id) }

  end

  context "#versionable_id" do

    before do
      subject.valid?
    end

    it "is set on validation" do
      expect(subject.versionable_id).to be_present
    end

    it "is set to a random UUID" do
      expect(subject.versionable_id).to match(UUID_REGEX)
    end

    it "doesn't change if already set" do
      subject.versionable_id = SecureRandom.uuid
      expect { subject.valid? }.not_to change { subject.versionable_id }
    end

  end

end
