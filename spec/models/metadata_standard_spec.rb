# frozen_string_literal: true

require 'rails_helper'

describe MetadataStandard do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :research_outputs }
  end

  context 'scopes' do
    before do
      @name_part = 'Foobar'
      @by_title = create(:metadata_standard, title: [Faker::Lorem.sentence, @name_part].join(' '))
      desc = [@name_part, Faker::Lorem.paragraph].join(' ')
      @by_description = create(:metadata_standard, description: desc)
    end

    it ':search returns the expected records' do
      results = described_class.search(@name_part)
      expect(results.include?(@by_title)).to be(true)
      expect(results.include?(@by_description)).to be(true)

      results = described_class.search('Zzzzzz')
      expect(results.include?(@by_title)).to be(false)
      expect(results.include?(@by_description)).to be(false)
    end
  end
end
