# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contributor, type: :model do

  context "validations" do
    subject { build(:contributor) }
    it { is_expected.to allow_values("one@example.com", "foo-bar@ed.ac.uk").for(:email) }
    it { is_expected.not_to allow_values("example.com", "foo bar@ed.ac.uk").for(:email) }
  end

  context "associations" do
    it { is_expected.to belong_to(:org) }

    it { is_expected.to have_many(:plans_contributors) }
    it { is_expected.to have_many(:plans) }
    it { is_expected.to have_many(:identifiers) }
  end

  context "instance methods" do

    describe "#name(last_first: false)" do
      before(:each) do
        @contributor = build(:contributor)
      end

      it "defaults to 'first last' format" do
        expected = "#{@contributor.firstname} #{@contributor.surname}"
        expect(@contributor.name).to eql(expected)
      end
      it "allows 'first last' format" do
        expected = "#{@contributor.firstname} #{@contributor.surname}"
        expect(@contributor.name(last_first: false)).to eql(expected)
      end
      it "allows 'last, first' format" do
        expected = "#{@contributor.surname}, #{@contributor.firstname}"
        expect(@contributor.name(last_first: true)).to eql(expected)
      end
    end

  end

end
