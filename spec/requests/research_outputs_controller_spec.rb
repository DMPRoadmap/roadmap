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
    it 'does not resolve the DOI again after successful verification' do
      datacite_request = stub_datacite_request(
        body: datacite_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      get fetch_doi_plan_research_outputs_path(plan, doi: doi)
      expect(response).to have_http_status(:ok)

      get new_plan_research_output_path(plan, prefill_doi: doi),
          headers: { 'Turbo-Frame' => 'research-output-form' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Example dataset')
      expect(datacite_request).to have_been_requested.once
    end

    it 'retains the verified metadata when a repeated provider lookup would fail' do
      stub_request(:get, "#{datacite_base_url}/dois/#{CGI.escape(doi)}")
        .with(headers: { 'Accept' => 'application/vnd.api+json' })
        .to_return(
          {
            status: 200,
            body: datacite_json,
            headers: { 'Content-Type' => 'application/json' }
          },
          { status: 500 }
        )
      stub_crossref_request(status: 500)

      get fetch_doi_plan_research_outputs_path(plan, doi: doi)
      expect(response).to have_http_status(:ok)

      get new_plan_research_output_path(plan, prefill_doi: doi),
          headers: { 'Turbo-Frame' => 'research-output-form' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Example dataset')
    end

    context 'when navigating directly without calling fetch_doi first' do
      it 'pre-fills metadata directly if provider lookup succeeds' do
        stub_datacite_request(body: datacite_json, headers: { 'Content-Type' => 'application/json' })

        get new_plan_research_output_path(plan, prefill_doi: doi)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Example dataset')
        expect(flash[:alert]).to be_nil
      end

      it 'displays a flash alert warning if direct lookup fails' do
        stub_datacite_request(status: 500)
        stub_crossref_request(status: 500)

        get new_plan_research_output_path(plan, prefill_doi: doi)

        expect(response).to have_http_status(:ok)
        expect(flash.now[:alert]).to eq('Unable to fetch metadata for the provided DOI. Showing empty form.')
      end
    end
  end

  describe 'GET /plans/:plan_id/research_outputs/fetch_doi' do
    context 'with a valid DOI' do
      it 'returns a successful 200 OK JSON response' do
        stub_datacite_request(body: datacite_json, headers: { 'Content-Type' => 'application/json' })

        get fetch_doi_plan_research_outputs_path(plan, doi: doi)

        expect(response.code).to eql('200')
        expect(response.content_type).to include('application/json')

        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq('Example dataset')
        expect(json_response['output_type']).to eq('dataset')
        expect(json_response['release_date']).to eq('2021-05-12')
      end
    end

    context 'when DOI parameter is missing' do
      it 'returns a 400 Bad Request JSON response' do
        get fetch_doi_plan_research_outputs_path(plan, doi: '')

        expect(response.code).to eql('400')
        expect(JSON.parse(response.body)['error']).to eq('DOI is required.')
      end
    end

    context 'when the service cannot find the DOI' do
      before do
        # stub both services to return 404
        stub_datacite_request(target_doi: '10.5281/not-found', status: 404, body: '')
        stub_crossref_request(target_doi: '10.5281/not-found', status: 404, body: '')
      end

      it 'returns a 404 Not Found JSON response' do
        get fetch_doi_plan_research_outputs_path(plan, doi: '10.5281/not-found')
        expect(response.code).to eql('404')
      end
    end

    context 'when providers encounter a timeout or outage' do
      before do
        stub_datacite_request(status: 500)
        stub_crossref_request(status: 500)
      end

      it 'returns a 503 Service Unavailable status' do
        get fetch_doi_plan_research_outputs_path(plan, doi: doi)

        expect(response.code).to eql('503')
        expect(JSON.parse(response.body)['error']).to include('service is currently unavailable')
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
