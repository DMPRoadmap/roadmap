# frozen_string_literal: true

module Mocks
  module DataciteMocks
    BASE_API_URL = 'https://api.test.datacite.org/'

    ERROR_RESPONSE = File.read(
      Rails.root.join('spec', 'support', 'mocks', 'datacite', 'error.json')
    ).freeze

    SUCCESS_RESPONSE = File.read(
      Rails.root.join('spec', 'support', 'mocks', 'datacite', 'success.json')
    ).freeze

    def stub_minting_success!
      stub_request(:post, "#{BASE_API_URL}dois")
        .to_return(status: 200, body: SUCCESS_RESPONSE, headers: {})
    end

    def stub_minting_error!
      stub_request(:post, "#{BASE_API_URL}dois")
        .to_return(status: 400, body: ERROR_RESPONSE, headers: {})
    end

    def stub_update_success!
      stub_request(:put, %r{#{BASE_API_URL}dois/.*})
        .to_return(status: 200, body: SUCCESS_RESPONSE, headers: {})
    end

    def stub_update_error!
      stub_request(:put, %r{#{BASE_API_URL}dois/.*})
        .to_return(status: 500, body: ERROR_RESPONSE, headers: {})
    end
  end
end
