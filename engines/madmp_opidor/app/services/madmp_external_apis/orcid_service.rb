# frozen_string_literal: true

module MadmpExternalApis
  # This service provides an interface to ORCiD API
  class OrcidService < ::ExternalApis::BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.orcid&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.orcid&.api_base_url || super
      end

      def active?
        Rails.configuration.x.orcid&.active || super
      end

      def search_path
        Rails.configuration.x.orcid&.search_path
      end

      def default_rows
        Rails.configuration.x.orcid.default_rows
      end

      # Ping the ORCiD API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active?

        resp = http_get(uri: "#{api_base_url}#{search_path}")
        resp&.code == 200
      end

      # Search the ORCiD API for the given string.
      def search(term:, rows:)
        return [] unless active? && term.present? && ping

        parse_expanded_result(json: query_orcid(term:, rows:), term:)
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'ORCiD search', error: e)
        []
      end

      private

      # Queries the ORCiD API for the sepcified name and page
      def query_orcid(term:, rows:)
        return [] unless term

        # Call the ROR API and log any errors
        resp = http_get(
          uri: "#{api_base_url}#{search_path}?q=#{term}&rows=#{rows.nil? ? default_rows : rows}",
          additional_headers: { Accept: 'application/vnd.orcid+json' },
          debug: false
        )

        return [] unless resp&.code == 200

        JSON.parse(resp.body)
      rescue StandardError
        handle_http_failure(method: 'ORCiD search', http_response: resp)
        []
      end

      # Convert the JSON items into a hash
      def parse_expanded_result(json:, term:)
        return [] unless json['expanded-result']&.any?

        regex = /^([a-z0-9]{4})-([a-z0-9]{4})-([a-z0-9]{4})-([a-z0-9]{4})$/i
        data = json['expanded-result']

        data = data.select { |item| regex.match(term) ? item['orcid-id'] == term : true }

        data.map do |item|
          {
            orcid: item&.dig('orcid-id').to_s,
            givenNames: item&.dig('given-names').to_s,
            familyNames: item&.dig('family-names').to_s,
            institutionName: item&.dig('institution-name') || []
          }
        end&.compact
      end
    end
  end
end
