# frozen_string_literal: true

require "rails_helper"

RSpec.describe Role, type: :model do
  include RolesHelper

  context "validations" do
    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:plan) }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }

    it {
      is_expected.to validate_numericality_of(:access)
        .only_integer
        .is_greater_than(0)
        .with_message("can't be less than zero")
    }

  end

  context "associations" do

    it { is_expected.to belong_to :user }

    it { is_expected.to belong_to :plan }

  end

  describe ".deactivate!" do
    before do
      @plan = build_plan(true, true, true)
    end

    subject { @plan }

    context "different access levels" do

      it "creator is no longer active" do
        role = subject.roles.creator.first
        role.deactivate!
        expect(role.active).to eql(false)
      end

      it "administrator is no longer active" do
        @role = subject.roles.administrator.first
        @role.deactivate!
        expect(@role.active).to eql(false)
      end

      it "editor is no longer active" do
        @role = subject.roles.editor.first
        @role.deactivate!
        expect(@role.active).to eql(false)
      end

      it "commenter is no longer active" do
        @role = subject.roles.commenter.first
        @role.deactivate!
        expect(@role.active).to eql(false)
      end

    end

    context "Deactivation calls Plan.deactivate! if Plan.authors is empty" do

      it "plan has no other authors" do
        plan = build_plan(false, false, false)
        role = plan.roles.creator.first
        role.plan.expects(:deactivate!).times(1)
        role.deactivate!
      end

      it "plan has another author" do
        plan = build_plan(true, false, false)
        role = plan.roles.creator.first
        role.plan.expects(:deactivate!).times(0)
        role.deactivate!
      end

    end

  end

end
