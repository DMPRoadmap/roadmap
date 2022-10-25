# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Theme do
  context 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  context 'associations' do
    it {
      expect(subject).to have_and_belong_to_many(:questions)
        .join_table('questions_themes')
    }

    it {
      expect(subject).to have_and_belong_to_many(:guidances)
        .join_table('themes_in_guidance')
    }
  end

  describe '.search' do
    subject { described_class.search(term) }

    let!(:term) { 'foo' }

    context 'when neither title or description matches term' do
      let!(:theme) { create(:theme) }

      it { is_expected.not_to include(theme) }
    end

    context 'when title is a match for term' do
      let!(:theme) { create(:theme, title: 'The title is foo bar') }

      it { is_expected.to include(theme) }
    end

    context 'when description is a match for term' do
      let!(:theme) { create(:theme, description: 'The title is foo bar') }

      it { is_expected.to include(theme) }
    end
  end

  describe '#to_s' do
    subject { theme.to_s }

    let!(:theme) { create(:theme) }

    it 'returns the title' do
      expect(subject).to eql(theme.title)
    end
  end
end
