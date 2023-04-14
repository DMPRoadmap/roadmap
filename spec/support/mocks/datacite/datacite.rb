# frozen_string_literal: true

module Mocks
  module DataciteMocks
    DATACITE_BASE_API_URL = 'https://api.test.datacite.org/'

    DATACITE_ERROR_RESPONSE = Rails.root.join('spec', 'support', 'mocks', 'datacite', 'error.json').read.freeze

    DATACITE_SUCCESS_RESPONSE = Rails.root.join('spec', 'support', 'mocks', 'datacite', 'success.json').read.freeze

    def stub_minting_success!
      stub_request(:post, "#{DATACITE_BASE_API_URL}dois")
        .to_return(status: 200, body: DATACITE_SUCCESS_RESPONSE, headers: {})
    end

    def stub_minting_error!
      stub_request(:post, "#{DATACITE_BASE_API_URL}dois")
        .to_return(status: 400, body: DATACITE_ERROR_RESPONSE, headers: {})
    end

    def stub_update_success!
      stub_request(:put, %r{#{DATACITE_BASE_API_URL}dois/.*}o)
        .to_return(status: 200, body: DATACITE_SUCCESS_RESPONSE, headers: {})
    end

    def stub_update_error!
      stub_request(:put, %r{#{DATACITE_BASE_API_URL}dois/.*}o)
        .to_return(status: 500, body: DATACITE_ERROR_RESPONSE, headers: {})
    end
  end
end
