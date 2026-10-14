# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResearchOutputs DOI Fetching', type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:plan) }
  let(:doi) { '10.5281/zenodo.4884775' }
  let(:datacite_base_url) { 'https://api.datacite.org' }
  let(:crossref_base_url) { 'https://api.crossref.org' }

  let(:datacite_json) do
    {
      data: {
        attributes: {
          titles: [{ title: 'Example dataset' }],
          descriptions: [
            { description: 'Abstract description text...', descriptionType: 'Abstract' }
          ],
          types: { resourceTypeGeneral: 'Dataset' },
          dates: [{ date: '2021-05-12', dateType: 'Issued' }]
        }
      }
    }.to_json
  end

  before do
    create(:role, :creator, user: user, plan: plan)

    sign_in user

    Rails.configuration.x.datacite.active = true
    Rails.configuration.x.crossref.active = true

    Rails.cache.clear
  end

  describe 'GET /plans/:plan_id/research_outputs/new with DOI prefill' do
    it 'resolves the DOI once and pre-fills the form' do
      datacite_request = stub_datacite_request(
        body: datacite_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      get new_plan_research_output_path(plan, prefill_doi: doi)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Example dataset')
      document = Nokogiri::HTML(response.body)
      expect(document.at_css('#research_output_output_type option[selected]')['value']).to eq('dataset')
      expect(document.at_css('#research_output_release_date')['value']).to eq('2021-05-12')
      expect(flash[:alert]).to be_nil
      expect(datacite_request).to have_been_requested.once
    end

    it 'supports metadata larger than the cookie session limit' do
      large_description = "A long abstract #{'content ' * 800}"
      large_datacite_json = JSON.parse(datacite_json)
      large_datacite_json['data']['attributes']['descriptions'][0]['description'] = large_description
      stub_datacite_request(
        body: large_datacite_json.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      get new_plan_research_output_path(plan, prefill_doi: doi)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('A long abstract')
      expect(session[:doi_prefill_data]).to be_nil
    end

    it 'rejects an invalid DOI without calling providers' do
      datacite_request = stub_request(:get, /api\.datacite\.org/)
      crossref_request = stub_request(:get, /api\.crossref\.org/)

      get new_plan_research_output_path(plan, prefill_doi: 'xxxx 10.1234/example')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Does not appear to be a valid DOI.')
      expect(datacite_request).not_to have_been_requested
      expect(crossref_request).not_to have_been_requested
    end

    context 'when resolving the DOI fails' do
      it 'tells the user when providers are unavailable' do
        stub_datacite_request(status: 500)
        stub_crossref_request(status: 500)

        get new_plan_research_output_path(plan, prefill_doi: doi)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('DOI lookup service is currently unavailable')
      end

      it 'tells the user when metadata cannot be found' do
        missing_doi = '10.5281/not-found'
        stub_datacite_request(target_doi: missing_doi, status: 404)
        stub_crossref_request(target_doi: missing_doi, status: 404)

        get new_plan_research_output_path(plan, prefill_doi: missing_doi)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Could not find metadata for the provided DOI.')
      end
    end
  end

  private

  def stub_datacite_request(target_doi: doi, status: 200, body: '', headers: {})
    escaped_path = CGI.escape(target_doi)

    stub_request(:get, "#{datacite_base_url}/dois/#{escaped_path}")
      .with(headers: { 'Accept' => 'application/vnd.api+json' })
      .to_return(status: status, body: body, headers: headers)
  end

  def stub_crossref_request(target_doi: doi, status: 200, body: '', headers: {})
    escaped_path = CGI.escape(target_doi)

    stub_request(:get, "#{crossref_base_url}/works/#{escaped_path}")
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: status, body: body, headers: headers)
  end
end
