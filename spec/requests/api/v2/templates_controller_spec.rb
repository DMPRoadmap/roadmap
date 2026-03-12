# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::TemplatesController do
  include ApiHelper

  before do
    @user = create(:user)
    @client = create(:oauth_application)
    token = mock_authorization_code_token(oauth_application: @client, user: @user).plaintext_token

    @headers = {
      Accept: 'application/json',
      'Content-Type': 'application/json',
      Authorization: "Bearer #{token}"
    }
  end

  def fetch_templates_json_response
    get(api_v2_templates_path, headers: @headers)
    expect(response).to render_template('api/v2/_standard_response')
    expect(response).to render_template('api/v2/templates/index')
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'GET /api/v2/templates (index)' do
    context 'an invalid API token is included' do
      it 'returns 401 if the token is invalid' do
        @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
        get(api_v2_templates_path, headers: @headers)

        expect(response.code).to eql('401')
        expect(response.body).to be_empty

        # Expect Doorkeeper to return the standard OAuth 2.0 WWW-Authenticate header for invalid tokens
        expect(response.headers['WWW-Authenticate']).to match(
          /Bearer realm="Doorkeeper", error="invalid_token", error_description="The access token is invalid"/
        )
      end
    end

    context 'a valid API token is included' do
      it 'returns a 200 and the expected response body' do
        json = fetch_templates_json_response

        # Items array is empty
        expect(json[:items]).to eq([])

        # total_items reflects that nothing is returned
        expect(json[:total_items]).to eq(0)

        # Status code and message are correct
        expect(json[:code]).to eq(200)
        expect(json[:message]).to eq('OK')

        # Application and source are present and sensible
        expect(json[:application]).to eq(ApplicationService.application_name)
        expect(json[:source]).to eq('GET /api/v2/templates')

        # Time is present and parseable
        expect { Time.iso8601(json[:time]) }.not_to raise_error

        # Caller is included
        expect(json[:caller]).to eq(@client.name)
      end

      it 'returns an empty array if no templates are available' do
        get(api_v2_templates_path, headers: @headers)

        expect(response.code).to eql('200')
        expect(response).to render_template('api/v2/_standard_response')
        expect(response).to render_template('api/v2/templates/index')

        json = JSON.parse(response.body).with_indifferent_access
        expect(json[:items].empty?).to be(true)
        expect(json[:errors].nil?).to be(true)
      end

      it 'returns the expected templates' do
        # See `app/policies/api/v2/templates_policy.rb for templates included/excluded via `GET api/v2/templates`

        # All included templates must be published and are either:
        # - 1) organisationally_visible and template.org_id == user.org_id
        # - 2) publicly_visible and customization of == nil

        public_template = create(:template, :publicly_visible, published: true)

        included_templates = [
          public_template,
          create(:template, :organisationally_visible, published: true, org: @user.org)
        ]

        # excluded_templates
        # unpublished template
        create(:template, :publicly_visible, published: false, org: @user.org)
        # organisationally_visible and template.org_id != user.org_id
        create(:template, :organisationally_visible, published: true)
        # publicly_visible and customization of != nil
        create(:template, :publicly_visible, published: true, customization_of: public_template.family_id)

        json = fetch_templates_json_response

        expect(json[:items].length).to be(2)
        template_ids = json[:items].map { |item| item[:dmp_template][:template_id][:identifier] }
        expect(template_ids).to match_array(included_templates.map { |t| t.id.to_s })
      end

      it 'allows for paging' do
        original_page_size = Rails.configuration.x.application.api_max_page_size
        Rails.configuration.x.application.api_max_page_size = 10
        create_list(:template, 11, visibility: 1, published: true)
        get(api_v2_templates_path, headers: @headers)

        test_paging(json: JSON.parse(response.body), headers: @headers)
        Rails.configuration.x.application.api_max_page_size = original_page_size
      end
    end
  end
end
