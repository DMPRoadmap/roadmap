# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResearchOutputs DOI Fetching', type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:plan) }
  let!(:doi_scheme) do
    create(:identifier_scheme, name: 'doi', identifier_prefix: 'https://doi.org', active: true)
  end
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
      expect(document.at_css('#doi_lookup_input')['value']).to eq(doi)
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
      invalid_doi = 'xxxx 10.1234/example'
      datacite_request = stub_request(:get, /api\.datacite\.org/)
      crossref_request = stub_request(:get, /api\.crossref\.org/)

      get new_plan_research_output_path(plan, prefill_doi: invalid_doi)

      expect(response).to redirect_to(plan_research_outputs_path(plan, prefill_doi: invalid_doi))
      expect(datacite_request).not_to have_been_requested
      expect(crossref_request).not_to have_been_requested

      follow_redirect!

      expect(response.body).to include('Does not appear to be a valid DOI.')
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

        expect(response).to redirect_to(plan_research_outputs_path(plan, prefill_doi: missing_doi))

        follow_redirect!

        expect(response.body).to include('Could not find metadata for the provided DOI.')
      end
    end
  end

  describe 'DOI persistence on research outputs' do
    let(:research_output_params) do
      {
        title: 'Output with DOI',
        output_type: 'dataset',
        access: 'open',
        prefill_doi: doi
      }
    end

    it 'persists the DOI identifier when creating a research output' do
      post plan_research_outputs_path(plan), params: { prefill_doi: doi, research_output: research_output_params }

      expect(response).to redirect_to(plan_research_outputs_path(plan))

      research_output = ResearchOutput.order(:id).last
      identifier = research_output.identifier_for_scheme(scheme: 'doi')
      expect(identifier).to be_present
      expect(identifier.value_without_scheme_prefix).to eq(doi)
    end

    it 'replaces the DOI identifier when updating a research output' do
      research_output = create(:research_output, plan: plan, repositories_count: 0, metadata_standards_count: 0)
      research_output.identifiers.create!(identifier_scheme: doi_scheme, value: '10.1111/original-doi')

      patch plan_research_output_path(plan, research_output), params: {
        prefill_doi: doi,
        research_output: {
          title: research_output.title,
          output_type: research_output.output_type,
          access: research_output.access
        }
      }

      expect(response).to redirect_to(plan_research_outputs_path(plan))

      research_output.reload
      identifier = research_output.identifier_for_scheme(scheme: 'doi')
      expect(research_output.identifiers.where(identifier_scheme: doi_scheme).count).to eq(1)
      expect(identifier.value_without_scheme_prefix).to eq(doi)
    end

    it 'shows the persisted DOI on the edit form when no prefill param is supplied' do
      research_output = create(:research_output, plan: plan, repositories_count: 0, metadata_standards_count: 0)
      research_output.identifiers.create!(identifier_scheme: doi_scheme, value: doi)

      get edit_plan_research_output_path(plan, research_output)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      expect(document.at_css('#doi_lookup_input')['value']).to eq(doi)
    end

    it 'updates the existing research output from DOI prefill without creating a new record' do
      research_output = create(
        :research_output,
        plan: plan,
        title: 'Original title',
        description: 'Original description',
        output_type: 'text',
        release_date: '2020-01-01'
      )

      datacite_request = stub_datacite_request(
        body: datacite_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      get edit_plan_research_output_path(plan, research_output, prefill_doi: doi)

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML(response.body)
      expect(document.at_css('#research_output_title')['value']).to eq('Example dataset')
      expect(document.at_css('#research_output_release_date')['value']).to eq('2021-05-12')

      original_count = ResearchOutput.count

      patch plan_research_output_path(plan, research_output), params: {
        prefill_doi: doi,
        research_output: {
          title: 'Example dataset',
          description: 'Abstract description text...',
          output_type: 'dataset',
          access: research_output.access,
          release_date: '2021-05-12'
        }
      }

      expect(response).to redirect_to(plan_research_outputs_path(plan))
      expect(datacite_request).to have_been_requested.once
      expect(ResearchOutput.count).to eq(original_count)

      research_output.reload
      expect(research_output.title).to eq('Example dataset')
      expect(research_output.description).to include('Abstract description text...')
      expect(research_output.output_type).to eq('dataset')
      expect(research_output.release_date.to_date).to eq(Date.parse('2021-05-12'))
      expect(research_output.identifier_for_scheme(scheme: 'doi')&.value_without_scheme_prefix).to eq(doi)
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
