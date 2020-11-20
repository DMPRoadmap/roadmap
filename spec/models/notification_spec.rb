# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:notification_type) }

    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_presence_of(:level) }

    it { is_expected.to validate_presence_of(:body) }

    it { is_expected.to allow_values(true, false).for(:dismissable) }

    it { is_expected.not_to allow_value(nil).for(:dismissable) }

    it { is_expected.to allow_values(true, false).for(:enabled) }

    it { is_expected.not_to allow_value(nil).for(:enabled) }

    it { is_expected.to validate_presence_of(:starts_at) }

    it { is_expected.to validate_presence_of(:expires_at) }

    it { is_expected.to allow_value(Date.today).for(:starts_at) }

    it { is_expected.not_to allow_value(1.day.ago).for(:starts_at) }

    it { is_expected.to allow_value(2.days.from_now).for(:expires_at) }

    it { is_expected.not_to allow_value(Date.today).for(:expires_at) }

  end

  describe ".active" do

    subject { Notification.active }

    context "when enabled and now is before starts_at" do

      let!(:notification) do
        create(:notification, starts_at: 1.week.from_now,
                              enabled: true)
      end

      it { is_expected.not_to include(notification) }

    end

    context "when enabled and now lies between starts_at and expires_at" do

      let!(:notification) do
        record = build(:notification, starts_at: 1.day.ago,
                                      expires_at: 1.day.from_now,
                                      enabled: true)
        record.save(validate: false)
        record
      end

      it { is_expected.to include(notification) }

    end

    context "when enabled and now is after expires_at" do

      let!(:notification) do
        create(:notification, starts_at: 1.week.from_now, enabled: true)
      end

      it { is_expected.not_to include(notification) }

    end

    context "when disabled and now lies between starts_at and expires_at" do

      let!(:notification) do
        record = build(:notification, starts_at: 1.day.ago,
                                      expires_at: 1.day.from_now)
        record.save(validate: false)
        record
      end

      it { is_expected.not_to include(notification) }

    end

  end

  describe ".active_per_user" do

    context "when User is present and Notification is general" do

      let!(:notification) { create(:notification, :active) }

      let!(:user) { create(:user) }

      subject { Notification.active_per_user(user) }

      it { is_expected.to include(notification) }

    end

    context "when User is present and Notification belongs to User" do

      let!(:user) { create(:user) }

      let!(:notification) { create(:notification, :active) }

      before do
        notification.users << user
      end

      subject { Notification.active_per_user(user) }

      it { is_expected.not_to include(notification) }

    end

    context "when User is nil and Notification is dismissable" do

      let!(:user) { nil }

      let!(:notification) { create(:notification, :active, :dismissable) }

      subject { Notification.active_per_user(user) }

      it { is_expected.not_to include(notification) }

    end

    context "when User is nil and Notification is not dismissable" do

      let!(:user) { nil }

      let!(:notification) { create(:notification, :active) }

      subject { Notification.active_per_user(user) }

      it { is_expected.to include(notification) }

    end

    context "when User is present and Notification is disabled" do

      let!(:notification) { create(:notification, :active, enabled: false) }

      let!(:user) { create(:user) }

      subject { Notification.active_per_user(user) }

      it { is_expected.not_to include(notification) }

    end

    context "when User is nil and Notification is not dismissable or enabled" do

      let!(:user) { nil }

      let!(:notification) { create(:notification) }

      subject { Notification.active_per_user(user) }

      it { is_expected.not_to include(notification) }

    end
  end

  describe "#acknowledged?" do

    context "when dismissable, user present, and already acknowledged" do

      let!(:notification) { create(:notification, :dismissable) }

      let!(:user) { create(:user) }

      subject { notification.acknowledged?(user) }

      before do
        notification.users << user
      end

      it { is_expected.to eql(true) }

    end

    context "when not dismissable, user present, and already acknowledged" do

      let!(:notification) { create(:notification) }

      let!(:user) { create(:user) }

      subject { notification.acknowledged?(user) }

      before do
        notification.users << user
      end

      it { is_expected.to eql(false) }

    end

    context "when dismissable, user absent" do

      let!(:notification) { create(:notification, :dismissable) }

      let!(:user) { nil }

      subject { notification.acknowledged?(user) }

      it { is_expected.to eql(false) }

    end

    context "when dismissable, user absent, and not already acknowledged" do

      let!(:notification) { create(:notification, :dismissable) }

      let!(:user) { nil }

      subject { notification.acknowledged?(user) }

      it { is_expected.to eql(false) }

    end

    context "when not dismissable, user absent, and not already acknowledged" do

      let!(:notification) { create(:notification) }

      let!(:user) { nil }

      subject { notification.acknowledged?(user) }

      it { is_expected.to eql(false) }

    end

  end

end
