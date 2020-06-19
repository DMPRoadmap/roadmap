# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor, type: :model do

  context "validations" do

    it { is_expected.to validate_presence_of(:roles) }

    it "should validate that roles is greater than zero" do
      subject.name = Faker::Books::Dune.character
      subject.email = Faker::Internet.email
      is_expected.to validate_numericality_of(:roles)
        .with_message("You must specify at least one role.")
    end

    describe "#name_or_email_presence" do
      before(:each) do
        @contributor = build(:contributor, plan: create(:plan), investigation: true)
      end

      it "is invalid if both the name and email are blank" do
        @contributor.name = nil
        @contributor.email = nil
        expect(@contributor.valid?).to eql(false)
        expect(@contributor.errors[:name].present?).to eql(true)
        expect(@contributor.errors[:email].present?).to eql(true)
      end
      it "is valid if a name is present" do
        @contributor.email = nil
        expect(@contributor.valid?).to eql(true)
      end
      it "is valid if an email is present" do
        @contributor.name = nil
        expect(@contributor.valid?).to eql(true)
      end
    end

  end

  context "associations" do
    it { is_expected.to belong_to(:org) }
    it { is_expected.to belong_to(:plan) }
    it { is_expected.to have_many(:identifiers) }
  end

end
