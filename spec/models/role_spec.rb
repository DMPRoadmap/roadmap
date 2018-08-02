require 'rails_helper'

RSpec.describe Role, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:user) }

    it { is_expected.to validate_presence_of(:plan) }

    it { is_expected.to allow_values(true, false).for(:active) }

    it { is_expected.not_to allow_value(nil).for(:active) }

    it { is_expected.to validate_numericality_of(:access)
                          .only_integer
                          .is_greater_than(0)
                          .with_message("can't be less than zero") }

  end

  context "associations" do

    it { is_expected.to belong_to :user }

    it { is_expected.to belong_to :plan }

  end

  describe "#access_level" do

    subject { role.access_level }

    context "when Role is reviewer" do

      let!(:role) { build(:role, :reviewer) }

      it { is_expected.to eql(5) }

    end

    context "when Role is administrator" do

      let!(:role) { build(:role, :administrator) }

      it { is_expected.to eql(3) }

    end

    context "when Role is editor" do

      let!(:role) { build(:role, :editor) }

      it { is_expected.to eql(2) }

    end

    context "when Role is commenter" do

      let!(:role) { build(:role, :commenter) }

      it { is_expected.to eql(1) }

    end

  end

  describe "#access_level=" do

    let!(:role) { build(:role).tap { |r| r.access_level = 0} }

    subject { role }

    context "when value is 0" do

      before do
        role.access_level = 0
      end

      it "sets commenter to false" do
        expect(subject).not_to be_commenter
      end

      it "sets editor to false" do
        expect(subject).not_to be_editor
      end

      it "sets administrator to false" do
        expect(subject).not_to be_administrator
      end

    end

    context "when value is 1" do

      before do
        role.access_level = 1
      end

      it "sets commenter to true" do
        expect(subject).to be_commenter
      end

      it "sets editor to false" do
        expect(subject).not_to be_editor
      end

      it "sets administrator to false" do
        expect(subject).not_to be_administrator
      end

    end

    context "when value is 2" do

      before do
        role.access_level = 2
      end

      it "sets commenter to true" do
        expect(subject).to be_commenter
      end

      it "sets editor to true" do
        expect(subject).to be_editor
      end

      it "sets administrator to false" do
        expect(subject).not_to be_administrator
      end

    end

    context "when value is 3" do

      before do
        role.access_level = 3
      end

      it "sets commenter to true" do
        expect(subject).to be_commenter
      end

      it "sets editor to true" do
        expect(subject).to be_editor
      end

      it "sets administrator to true" do
        expect(subject).to be_administrator
      end

    end

    context "when value is 4" do

      before do
        role.access_level = 4
      end

      it "sets commenter to true" do
        expect(subject).to be_commenter
      end

      it "sets editor to true" do
        expect(subject).to be_editor
      end

      it "sets administrator to true" do
        expect(subject).to be_administrator
      end

    end

  end

end
