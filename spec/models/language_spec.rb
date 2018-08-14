require 'rails_helper'

RSpec.describe Language, type: :model do

  context "validations" do

    subject { build(:language) }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(20) }

    it { is_expected.to validate_presence_of(:abbreviation) }

    it { is_expected.to validate_uniqueness_of(:abbreviation)
                          .with_message("must be unique") }

    it { is_expected.to allow_values('en', 'en_GB').for(:abbreviation) }

    it { is_expected.not_to allow_value('NOOP', 'en_', 'EN')
                              .for(:abbreviation) }

    it { is_expected.to validate_length_of(:abbreviation).is_at_most(5) }

  end

  context "associations" do

    it { is_expected.to have_many :users }

    it { is_expected.to have_many :orgs }

  end

  describe ".sorted_by_abbreviation" do

    before do
      create(:language, abbreviation: "aa")
      create(:language, abbreviation: "ab")
      create(:language, abbreviation: "ac")
    end

    it "sorts Languages by abbreviation in alphabetical order" do
      l1 = Language.find_by(abbreviation: "aa")
      expect(Language.sorted_by_abbreviation.first).to eql(l1)

      l2 = Language.find_by(abbreviation: "ab")
      expect(Language.sorted_by_abbreviation.second).to eql(l2)

      l3 = Language.find_by(abbreviation: "ac")
      expect(Language.sorted_by_abbreviation.third).to eql(l3)
    end

  end

  describe ".default" do

    subject { Language.default }

    context "when langauge is default_language" do

      let!(:language) { create(:language, default_language: true) }

      it { is_expected.to eql(language) }

    end

    context "when language is not default_language" do

      let!(:language) { create(:language, default_language: false) }

      it { is_expected.not_to eql(language) }

    end

  end

  describe ".id_for" do

    subject  { Language.id_for("fu") }

    context "when abbreviation is valid" do

      let!(:language) { create(:language, abbreviation: "fu") }

      it "returns the id for language with that abbreviation" do
        expect(subject).to eql(language.id)
      end

    end

    context "when abbreviation is invalid" do

      it "returns empty array" do
        expect(subject).to be_empty
      end

    end

  end

end
