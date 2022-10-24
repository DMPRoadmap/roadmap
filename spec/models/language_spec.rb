# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Language, type: :model do
  before(:each) do
    # The default language is created in the locales support file
    Language.destroy_all
  end

  context 'validations' do
    subject { build(:language, abbreviation: 'foo') }

    it { is_expected.to validate_presence_of(:name) }

    it { is_expected.to validate_length_of(:name).is_at_most(20) }

    it { is_expected.to validate_presence_of(:abbreviation) }

    it 'is expected to validate uniquenss of abbreviation' do
      @language = build(:language, abbreviation: create(:language, abbreviation: 'bar').abbreviation)
      expect(@language).not_to be_valid
      expect(@language).to have(1).errors_on(:abbreviation)
    end

    it { is_expected.to allow_values('en', 'en-GB').for(:abbreviation) }
  end

  context 'associations' do
    it { is_expected.to have_many :users }

    it { is_expected.to have_many :orgs }
  end

  describe '.sorted_by_abbreviation' do
    before do
      create(:language, abbreviation: 'aa')
      create(:language, abbreviation: 'ab')
      create(:language, abbreviation: 'ac')
    end

    it 'sorts Languages by abbreviation in alphabetical order' do
      l1 = Language.find_by(abbreviation: 'aa')
      expect(Language.sorted_by_abbreviation.first).to eql(l1)

      l2 = Language.find_by(abbreviation: 'ab')
      expect(Language.sorted_by_abbreviation.second).to eql(l2)

      l3 = Language.find_by(abbreviation: 'ac')
      expect(Language.sorted_by_abbreviation.third).to eql(l3)
    end
  end

  describe '.default' do
    subject { Language.default }

    context 'when langauge is default_language' do
      let!(:language) { create(:language, abbreviation: 'foo', default_language: true) }

      it { is_expected.to eql(language) }
    end

    context 'when language is not default_language' do
      let!(:language) { create(:language, abbreviation: 'foo', default_language: false) }

      it { is_expected.not_to eql(language) }
    end
  end

  describe '.id_for' do
    subject { Language.id_for('fu') }

    context 'when abbreviation is valid' do
      let!(:language) { create(:language, abbreviation: 'fu') }

      it 'returns the id for language with that abbreviation' do
        expect(subject).to eql(language.id)
      end
    end

    context 'when abbreviation is invalid' do
      it 'returns empty array' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#abbreviation' do
    context 'when region is present' do
      it 'forces the hyphenated format' do
        @language = Language.new(name: 'Esperanto', abbreviation: 'hh_XX')
        @language.valid?
        expect(@language.abbreviation).to eql('hh-XX')
      end

      it 'downcases the language component' do
        @language = Language.new(name: 'Esperanto', abbreviation: 'HH_XX')
        @language.valid?
        expect(@language.abbreviation).to start_with('hh')
      end

      it 'upcases the region' do
        @language = Language.new(name: 'Esperanto', abbreviation: 'hh_xx')
        @language.valid?
        expect(@language.abbreviation).to end_with('XX')
      end
    end

    context 'when region is absent' do
      it 'downases the given value' do
        @language = Language.new(name: 'Esperanto', abbreviation: 'HH')
        @language.valid?
        expect(@language.abbreviation).to eql('hh')
      end

      it "doesn't change well-formatted values" do
        @language = Language.new(name: 'Esperanto', abbreviation: 'hh')
        @language.valid?
        expect(@language.abbreviation).to eql('hh')
      end
    end
  end
end
