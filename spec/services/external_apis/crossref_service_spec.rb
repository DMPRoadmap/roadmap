# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::CrossrefService, type: :service do
  let(:doi) { '10.5281/zenodo.4884775' }

  before do
    Rails.configuration.x.crossref.active = true
  end

  describe '.parse_attributes' do
    context 'when given a valid JSON payload' do
      let(:raw_json) do
        {
          message: {
            title: ['Helper Function Test Title'],
            abstract: 'Explicit abstract text.',
            type: 'dataset',
            issued: { 'date-parts': [[2023, 5, 12]] }
          }
        }.to_json
      end

      it 'correctly extracts and structures all metadata fields' do
        result = described_class.parse_attributes(raw_json, doi)

        expect(result).to eq({
                               title: 'Helper Function Test Title',
                               description: 'Explicit abstract text.',
                               output_type: :dataset,
                               release_date: '2023-5-12',
                               doi: doi
                             })
      end
    end

    context 'when the payload is missing message attributes entirely' do
      it 'returns nil safely without raising an error' do
        empty_json = { message: {} }.to_json

        expect(described_class.parse_attributes(empty_json, doi)).to be_nil
      end
    end
  end

  describe 'description extraction helpers' do
    context 'when the abstract field is empty or nil' do
      let(:empty_desc_json) do
        {
          message: {
            title: ['No Description Output'],
            abstract: nil,
            type: 'dataset'
          }
        }.to_json
      end

      it 'returns nil for the description field' do
        result = described_class.parse_attributes(empty_desc_json, doi)

        expect(result[:description]).to be_nil
      end
    end
  end

  describe 'type mapping helpers' do
    context 'when Crossref returns an unmapped or missing type' do
      let(:unknown_type_json) do
        {
          message: {
            title: ['Unknown Type Output'],
            type: 'unrecognized-custom-type'
          }
        }.to_json
      end

      it 'defaults the output type symbol to :other' do
        result = described_class.parse_attributes(unknown_type_json, doi)

        expect(result[:output_type]).to eq(:other)
      end
    end

    context 'when mapping standard known Crossref general types' do
      it 'correctly translates specific types into application symbols' do
        dataset_json = { message: { title: ['T'], type: 'dataset' } }.to_json
        article_json = { message: { title: ['T'], type: 'journal-article' } }.to_json

        expect(described_class.parse_attributes(dataset_json, doi)[:output_type]).to eq(:dataset)
        expect(described_class.parse_attributes(article_json, doi)[:output_type]).to eq(:text)
      end
    end
  end
end
