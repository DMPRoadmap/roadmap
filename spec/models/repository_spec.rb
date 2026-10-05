# frozen_string_literal: true

# == Schema Information
#
# Table name: repositories
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  description  :text
#  url          :string
#  contact      :string
#  info         :json
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_repositories_on_name      (name)
#  index_repositories_on_url       (url)
#

require 'rails_helper'

describe Repository do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many :research_outputs }
  end

  context 'scopes' do
    before(:each) do
      @types = %w[Armadillo Barracuda]
      @subjects = %w[Capybara Dingo]
      @keywords = %w[Elephant Falcon]

      @never_found = create(:repository, name: 'foo', info: { types: [@types.last],
                                                              subjects: [@subjects.last],
                                                              keywords: [@keywords.last] })

      @by_type = create(:repository, info: { types: [@types.first],
                                             subjects: [@subjects.last],
                                             keywords: [@keywords.last] })
      @by_subject = create(:repository, info: { types: [@types.last],
                                                subjects: [@subjects.first],
                                                keywords: [@keywords.last] })
      @by_facet = create(:repository, info: { types: [@types.last],
                                              subjects: [@subjects.last],
                                              keywords: [@keywords.first] })
    end

    describe '#by_type' do
      it 'returns the expected repositories' do
        results = described_class.by_type(@types.first)
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(@by_type)).to eql(true)
        expect(results.include?(@by_subject)).to eql(false)
        expect(results.include?(@by_facet)).to eql(false)
      end
    end

    describe '#by_subject' do
      it 'returns the expected repositories' do
        results = described_class.by_subject(@subjects.first)
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(@by_type)).to eql(false)
        expect(results.include?(@by_subject)).to eql(true)
        expect(results.include?(@by_facet)).to eql(false)
      end
    end

    describe '#by_facet' do
      it 'returns the expected repositories' do
        results = described_class.by_facet(@keywords.first)
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(@by_type)).to eql(false)
        expect(results.include?(@by_subject)).to eql(false)
        expect(results.include?(@by_facet)).to eql(true)
      end
    end

    describe '#search' do
      it 'returns repositories with keywords like the search term' do
        results = described_class.search(@keywords.first[1..3])
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(@by_type)).to eql(false)
        expect(results.include?(@by_subject)).to eql(false)
        expect(results.include?(@by_facet)).to eql(true)
      end
      it 'returns repositories with subjects like the search term' do
        results = described_class.search(@by_subject.name[1..(@by_subject.name.length - 1)])
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(@by_type)).to eql(false)
        expect(results.include?(@by_subject)).to eql(true)
      end
      it 'returns repositories with name like the search term' do
        repo = create(:repository, name: [Faker::Lorem.word, @by_subject.name].join(' '))
        results = described_class.search(@by_subject.name[1..(@by_subject.name.length - 1)])
        expect(results.include?(@never_found)).to eql(false)
        expect(results.include?(repo)).to eql(true)
      end
    end
  end
end
