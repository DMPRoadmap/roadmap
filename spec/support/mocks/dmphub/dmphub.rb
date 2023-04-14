# frozen_string_literal: true

module Mocks
  module DmphubMocks
    BASE_API_URL = 'https://api.test.dmphub.org/'

    ERROR_RESPONSE = Rails.root.join('spec', 'support', 'mocks', 'dmphub', 'error.json').read.freeze

    SUCCESS_RESPONSE = Rails.root.join('spec', 'support', 'mocks', 'dmphub', 'success.json').read.freeze

    TOKEN_SUCCESS_RESPONSE = {
      access_token: SecureRandom.uuid.to_s,
      token_type: 'Bearer',
      expires_in: Faker::Number.number(digits: 10),
      created_at: Time.zone.now.to_formatted_s(:iso8601)
    }.freeze

    TOKEN_FAILURE_RESPONSE = {
      application: Faker::Music::GratefulDead.song,
      status: 'Unauthorized',
      code: 401,
      time: Time.zone.now.to_formatted_s(:iso8601),
      caller: Faker::Internet.private_ip_v4_address,
      source: 'POST https://localhost:3001/api/v0/authenticate',
      total_items: 0,
      errors: { client_authentication: 'Invalid credentials' }
    }.freeze

    def stub_auth_success!
      stub_request(:post, "#{BASE_API_URL}authenticate")
        .to_return(status: 200, body: TOKEN_SUCCESS_RESPONSE.to_json, headers: {})
    end

    def stub_auth_error!
      stub_request(:post, "#{BASE_API_URL}authenticate")
        .to_return(status: 401, body: TOKEN_FAILURE_RESPONSE.to_json, headers: {})
    end

    def stub_minting_success!
      stub_request(:post, "#{BASE_API_URL}data_management_plans")
        .to_return(status: 201, body: SUCCESS_RESPONSE, headers: {})
    end

    def stub_minting_error!
      stub_request(:post, "#{BASE_API_URL}data_management_plans")
        .to_return(status: 400, body: ERROR_RESPONSE, headers: {})
    end

    def stub_update_success!
      stub_request(:put, %r{#{BASE_API_URL}data_management_plans/.*}o)
        .to_return(status: 200, body: SUCCESS_RESPONSE, headers: {})
    end

    def stub_update_error!
      stub_request(:put, %r{#{BASE_API_URL}data_management_plans/.*}o)
        .to_return(status: 500, body: ERROR_RESPONSE, headers: {})
    end
  end
end
