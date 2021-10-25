# frozen_string_literal: true

require "rails_helper"

RSpec.describe IdentifierScheme, type: :model do

  context "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(30) }

    it { is_expected.to allow_value("foo").for(:name) }

    it { is_expected.not_to allow_value("012").for(:name) }

    it { is_expected.to_not allow_value(nil).for(:name) }
  end

  context "associations" do
    it { is_expected.to have_many :identifiers }
  end

  context "scopes" do
    before(:each) do
      @scheme = create(:identifier_scheme, for_users: true, active: true)
    end

    describe "#active" do
      it "returns active identifier schemes" do
        expect(described_class.active.first).to eql(@scheme)
      end
      it "does not return inactive identifier schemes" do
        @scheme.update(active: false)
        expect(described_class.active.first).to eql(nil)
      end
    end

    describe "#by_name scope" do
      it "is case insensitive" do
        rslt = described_class.by_name(@scheme.name.upcase).first
        expect(rslt).to eql(@scheme)
      end

      it "returns the IdentifierScheme" do
        rslt = described_class.by_name(@scheme.name).first
        expect(rslt).to eql(@scheme)
      end

      it "returns empty ActiveRecord results if nothing is found" do
        rslts = described_class.by_name(Faker::Lorem.sentence)
        expect(rslts.empty?).to eql(true)
      end
    end
  end

  context "instance methods" do
    before(:each) do
      @scheme = build(:identifier_scheme)
    end

    describe "#name=(value)" do
      it "allows single word names" do
        @scheme.name = "foo"
        expect(@scheme.name).to eql("foo")
      end
      it "removes no alpha characters" do
        @scheme.name = " foo bar- "
        expect(@scheme.name).to eql("foobar")
      end
      it "sets everything to lower case" do
        @scheme.name = "FoO"
        expect(@scheme.name).to eql("foo")
      end
    end

  end

end
