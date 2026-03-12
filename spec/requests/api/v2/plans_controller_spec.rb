# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V2::PlansController do
  include ApiHelper
  include Mocks::ApiV2JsonSamples
  include Webmocks
  include IdentifierHelper

  context 'OAuth (authorization_code grant type) — on behalf of a user' do
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

    def fetch_plans_json_response
      get(api_v2_plans_path, headers: @headers)
      expect(response).to render_template('api/v2/_standard_response')
      expect(response).to render_template('api/v2/plans/index')
      JSON.parse(response.body).with_indifferent_access
    end

    describe 'GET /api/v2/plans (index)' do
      context 'an invalid API token is included' do
        it 'returns a 401 and the expected Oauth 2.0 headers' do
          # Swap actual token with a random string
          @headers['Authorization'] = "Bearer #{SecureRandom.uuid}"
          get(api_v2_plans_path, headers: @headers)

          expect(response.code).to eql('401')
          expect(response.body).to be_empty

          # Expect Doorkeeper to return the standard OAuth 2.0 WWW-Authenticate header for invalid tokens
          expect(response.headers['WWW-Authenticate']).to match(
            /Bearer realm="Doorkeeper", error="invalid_token", error_description="The access token is invalid"/
          )
        end
      end

      context 'a valid API token is included' do
        let(:json) { fetch_plans_json_response }
        it 'returns a 200 and the expected response body' do
          # Items array is empty
          expect(json[:items]).to eq([])

          # total_items reflects that nothing is returned
          expect(json[:total_items]).to eq(0)

          # Status code and message are correct
          expect(json[:code]).to eq(200)
          expect(json[:message]).to eq('OK')

          # Application and source are present and sensible
          expect(json[:application]).to eq(ApplicationService.application_name)
          expect(json[:source]).to eq('GET /api/v2/plans')

          # Time is present and parseable
          expect { Time.iso8601(json[:time]) }.not_to raise_error

          # Caller is included
          expect(json[:caller]).to eq(@client.name)
        end

        it 'returns an empty array if no plans are available' do
          # Items array is empty
          expect(json[:items]).to eq([])

          # total_items reflects that nothing is returned
          expect(json[:total_items]).to eq(0)
        end

        it 'returns the expected plans' do
          # See `app/policies/api/v2/plans_policy.rb for plans included/excluded via `GET api/v2/plans`

          # Create the included plans
          included_plans = [create(:plan, org: @user.org), create(:plan)]
          included_plans[0].add_user!(@user.id, :creator)
          # Add multiple roles for testing (ensure duplicate plans will not returned)
          included_plans[1].add_user!(@user.id, :editor)
          included_plans[1].add_user!(@user.id, :commenter)

          # Created the excluded plans
          create(:plan, :creator, org: @user.org)
          inactive_plan = create(:plan, :creator)
          inactive_plan.add_user!(@user.id, :editor)
          Role.where(plan_id: inactive_plan.id, user_id: @user.id).update!(active: false)

          expect(json[:items].length).to be(included_plans.length)

          # Api::V2::PlanPresenter.identifier uses api_v2_plan_url(@plan) to set the "identifier".
          # That url is constructed using `request.host` / "www.example.com"
          # api_v2_plan_url(@plan) within this test will construct the url via
          # default_url_options[:host] / "example.org"
          # Because the urls are misaligned, we will only compare the paths here.
          # TODO: Consider aligning default_url_options[:host] (in test.rb) with `request.host`
          returned_identifiers = json[:items].map { |item| item[:dmp][:dmp_id][:identifier] }
          returned_paths = returned_identifiers.map { |url| URI(url).path }
          expected_paths = included_plans.map { |plan| api_v2_plan_path(plan) }
          expect(returned_paths).to eq(expected_paths)
        end

        it 'allows for paging' do
          original_page_size = Rails.configuration.x.application.api_max_page_size
          Rails.configuration.x.application.api_max_page_size = 10

          create_list(:plan, 11, :publicly_visible) do |plan|
            plan.add_user!(@user.id, :commenter)
          end
          json = fetch_plans_json_response

          test_paging(json: json, headers: @headers)

          Rails.configuration.x.application.api_max_page_size = original_page_size
        end
      end
    end
  end
end
