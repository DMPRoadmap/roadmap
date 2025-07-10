# app/services/external_api/orion_service.rb

require 'net/http'
require 'uri'
require 'json'

module ExternalApis
  class OrionService
    ORION_URL = "http://74.220.18.40:8080/submit"

    def self.search_by_ror_id(ror_id)
      return { error: 'Missing ROR ID' } if ror_id.blank?

      payload = {
        cmd: "search_by_ror_id",
        value: [ror_id]
      }

      post_to_orion(payload)
    end

    def self.search_by_domain(domain)
      return { error: 'Missing domain' } if domain.blank?

      payload = {
        cmd: "search_by_domain",
        value: domain
      }

      post_to_orion(payload)
    end

    def self.post_to_orion(payload)
      uri = URI.parse(ORION_URL)

      response = Net::HTTP.post(
        uri,
        payload.to_json,
        { "Content-Type" => "application/json" }
      )

      JSON.parse(response.body)
    rescue JSON::ParserError
      { error: 'Invalid response from Orion' }
    rescue => e
      { error: e.message }
    end
  end
end
