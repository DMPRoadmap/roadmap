# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApis::DoiResolutionService, type: :service do
  let(:user) { create(:user) }
  let(:plan) { create(:plan) }
  let(:doi) { '10.5281/zenodo.4884775' }
  let(:datacite_base_url) { Rails.configuration.x.datacite.api_base_url }
  let(:crossref_base_url) { Rails.configuration.x.crossref.api_base_url }

  let(:datacite_body) do
    { data: { attributes: {
      titles: [{ title: 'DataCite Document' }],
      descriptions: [{ description: 'DataCite Abstract' }],
      types: { resourceTypeGeneral: 'Dataset' },
      dates: [
        { date: '2021-05-12', dateType: 'Issued' }
      ]
    } } }.to_json
  end

  let(:crossref_body) do
    { message: {
      title: ['Crossref Publication'],
      abstract: 'Crossref Abstract',
      type: 'journal-article',
      issued: { 'date-parts': [[2026, 7]] }
    } }.to_json
  end

  before do
    create(:role, :creator, user: user, plan: plan)

    Rails.configuration.x.datacite.active = true
    Rails.configuration.x.crossref.active = true

    Rails.cache.clear
  end

  describe '.fetch_metadata' do
    context 'when the DOI parameter is blank' do
      it 'returns a status of :blank' do
        expect(described_class.fetch_metadata(doi: '   ')).to eq({ status: :blank })
      end
    end

    context 'when the DOI fails pattern regex matching rules' do
      it 'returns a status of :invalid' do
        expect(described_class.fetch_metadata(doi: 'invalid-doi-string')).to eq({ status: :invalid })
      end
    end

    context 'when DataCite has the record' do
      it 'successfully cleans the input string, gets DataCite data, and ignores Crossref' do
        messy_doi = "  https://doi.org/#{doi}  "

        dc_stub = stub_request(:get, "#{datacite_base_url}/dois/10.5281%2Fzenodo.4884775")
                  .to_return(status: 200, body: datacite_body)

        cr_stub = stub_request(:get, %r{api.crossref.org/works/})

        result = described_class.fetch_metadata(doi: messy_doi)

        expect(result[:status]).to eq(:ok)
        expect(result[:metadata][:title]).to eq('DataCite Document')
        expect(result[:metadata][:doi]).to eq(doi)
        expect(result[:metadata][:release_date]).to eq('2021-05-12')
        expect(dc_stub).to have_been_requested
        expect(cr_stub).not_to have_been_requested
      end
    end

    context 'when DataCite fails but Crossref has the record' do
      it 'automatically falls back to Crossref' do
        dc_stub = stub_request(:get, "#{datacite_base_url}/dois/10.5281%2Fzenodo.4884775")
                  .to_return(status: 404, body: '')

        cr_stub = stub_request(:get, "#{crossref_base_url}/works/10.5281%2Fzenodo.4884775")
                  .to_return(status: 200, body: crossref_body)

        result = described_class.fetch_metadata(doi: doi)

        expect(result[:status]).to eq(:ok)
        expect(result[:metadata][:title]).to eq('Crossref Publication')
        expect(dc_stub).to have_been_requested
        expect(cr_stub).to have_been_requested
      end
    end

    context 'when both services fail to locate the asset' do
      it 'returns status :not_found safely' do
        stub_request(:get, /api.datacite.org/).to_return(status: 404)
        stub_request(:get, /api.crossref.org/).to_return(status: 404)

        expect(described_class.fetch_metadata(doi: doi)).to eq({ status: :not_found })
      end
    end

    context 'when a provider times out or encounters an error' do
      it 'returns status :service_unavailable when one provider times out and the other returns 404' do
        stub_request(:get, /api.datacite.org/).to_raise(Timeout::Error)
        stub_request(:get, /api.crossref.org/).to_return(status: 404)

        expect(described_class.fetch_metadata(doi: doi)).to eq({ status: :service_unavailable })
      end

      it 'returns status :service_unavailable when all providers are inactive' do
        Rails.configuration.x.datacite.active = false
        Rails.configuration.x.crossref.active = false

        expect(described_class.fetch_metadata(doi: doi)).to eq({ status: :service_unavailable })
      end
    end
  end

  describe '.execute_fetch' do
    context 'when a service is explicitly deactivated in the configuration' do
      it 'short-circuits instantly and returns inactive status without making network calls' do
        Rails.configuration.x.datacite.active = false

        dc_stub = stub_request(:get, /api.datacite.org/)

        result = described_class.send(:execute_fetch, ExternalApis::DataciteService, 'datacite', doi)

        expect(result).to eq(:inactive)
        expect(dc_stub).not_to have_been_requested
      end
    end

    context 'when the network layer encounters an error' do
      it 'gracefully intercepts HTTP timeouts and returns error status instead of crashing' do
        stub_request(:get, "#{datacite_base_url}/dois/10.5281%2Fzenodo.4884775")
          .to_raise(Timeout::Error)

        result = described_class.send(:execute_fetch, ExternalApis::DataciteService, 'datacite', doi)

        expect(result).to eq(:error)
      end

      it 'gracefully intercepts JSON response parsing exceptions' do
        stub_request(:get, "#{datacite_base_url}/dois/10.5281%2Fzenodo.4884775")
          .to_return(status: 200, body: 'Not Valid JSON { [')

        result = described_class.send(:execute_fetch, ExternalApis::DataciteService, 'datacite', doi)

        expect(result).to eq(:error)
      end
    end
  end

  describe '.sanitize_and_normalize_description' do
    it 'preserves supported formatting tags and attributes' do
      raw_html = '<p>This is <strong>bold</strong> and a <a href="https://my.org" title="Link">link</a>.</p>'
      result = described_class.sanitize_and_normalize_description(raw_html)

      expect(result).to eq('<p>This is <strong>bold</strong> and a <a href="https://my.org" title="Link">link</a>.</p>')
    end

    it 'converts known JATS XML elements into supported HTML' do
      jats_xml =
        '<jats:p>Abstract text with <jats:bold>bold</jats:bold> and <jats:italic>emphasis</jats:italic>.</jats:p>'
      result = described_class.sanitize_and_normalize_description(jats_xml)

      expect(result).to eq('<p>Abstract text with <strong>bold</strong> and <em>emphasis</em>.</p>')
    end

    it 'removes unknown/unsupported elements while retaining their text' do
      unsupported_markup = '<custom-tag>Header</custom-tag><p>Paragraph <unknown>inner text</unknown></p>'
      result = described_class.sanitize_and_normalize_description(unsupported_markup)

      expect(result).to eq('Header<p>Paragraph inner text</p>')
    end

    it 'strips scripts, event-handler attributes, and unsafe URLs' do
      malicious_input = <<~HTML
        <p>Safe text</p>
        <script>alert('XSS');</script>
        <a href="javascript:alert('XSS')" onclick="doEvil()">Bad Link</a>
        <img src="x" onerror="alert('XSS')">
      HTML

      result = described_class.sanitize_and_normalize_description(malicious_input)

      expect(result).not_to include('<script>')
      expect(result).not_to include('onclick')
      expect(result).not_to include('onerror')
      expect(result).not_to include('javascript:')
      expect(result).to eq("<p>Safe text</p>\n\n<a>Bad Link</a>")
    end

    it 'leaves plain-text descriptions unchanged' do
      plain_text = 'This is a simple plain text description without any HTML.'
      result = described_class.sanitize_and_normalize_description(plain_text)

      expect(result).to eq(plain_text)
    end
  end
end
