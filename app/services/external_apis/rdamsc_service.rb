# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to the RDA Metadata Standards Catalog (RDAMSC)
  # It extracts the list of Metadata Standards using two API endpoints from the first extracts
  # the list of subjects/concepts from the thesaurus and the second collects the standards
  # (aka schemes) and connects them to their appropriate subjects
  #
  # UI to see the standards: https://rdamsc.bath.ac.uk/scheme-index
  # API:
  # https://app.swaggerhub.com/apis-docs/alex-ball/rda-metadata-standards-catalog/2.0.0#/m/get_api2_m
  class RdamscService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.rdamsc&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.rdamsc&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.rdamsc&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.rdamsc&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.rdamsc&.max_redirects || super
      end

      def active?
        Rails.configuration.x.rdamsc&.active || super
      end

      def schemes_path
        Rails.configuration.x.rdamsc&.schemes_path
      end

      def thesaurus_path
        Rails.configuration.x.rdamsc&.thesaurus_path
      end

      def thesaurai
        Rails.configuration.x.rdamsc&.thesaurai
      end

      def fetch_metadata_standards
        query_schemes(path: "#{schemes_path}?pageSize=250")
      end

      private

      # Retrieves the full list of metadata schemes from the rdamsc API as JSON.
      # For example:
      # {
      #   "apiVersion": "2.0.0",
      #   "data": {
      #     "currentItemCount": 10,
      #     "items": [
      #       {
      #         "description": "<p>The Access to Biological Collections Data (ABCD) Schema</p>",
      #         "keywords": [
      #           "http://vocabularies.unesco.org/thesaurus/concept4011",
      #           "http://vocabularies.unesco.org/thesaurus/concept230",
      #           "http://rdamsc.bath.ac.uk/thesaurus/subdomain235",
      #           "http://vocabularies.unesco.org/thesaurus/concept223",
      #           "http://vocabularies.unesco.org/thesaurus/concept159",
      #           "http://vocabularies.unesco.org/thesaurus/concept162",
      #           "http://vocabularies.unesco.org/thesaurus/concept235"
      #         ],
      #         "locations": [
      #           { "type": "document", "url": "http://www.tdwg.org/standards/115/" },
      #           { "type": "website", "url": "http://wiki.tdwg.org/ABCD" }
      #         ],
      #         "mscid": "msc:m1",
      #         "relatedEntities": [
      #           { "id": "msc:m42", "role": "child scheme" },
      #           { "id": "msc:m43", "role": "child scheme" },
      #           { "id": "msc:m64", "role": "child scheme" },
      #           { "id": "msc:c1", "role": "input to mapping" },
      #           { "id": "msc:c3", "role": "output from mapping" },
      #           { "id": "msc:c14", "role": "output from mapping" },
      #           { "id": "msc:c18", "role": "output from mapping" },
      #           { "id": "msc:c23", "role": "output from mapping" },
      #           { "id": "msc:g11", "role": "user" },
      #           { "id": "msc:g44", "role": "user" },
      #           { "id": "msc:g45", "role": "user" }
      #         ],
      #         "slug": "abcd-access-biological-collection-data",
      #         "title": "ABCD (Access to Biological Collection Data)",
      #         "uri": "https://rdamsc.bath.ac.uk/api2/m1"
      #       }
      #     ]
      #   }
      # }
      def query_schemes(path:)
        json = query_api(path: path)
        return false unless json.present?

        process_scheme_entries(json: json)
        return true unless json.fetch('data', {})['nextLink'].present?

        query_schemes(path: json['data']['nextLink'])
      end

      def query_api(path:)
        return nil unless path.present?

        # Call the API and log any errors
        resp = http_get(uri: "#{api_base_url}#{path}", additional_headers: {}, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: "RDAMSC API query - path: '#{path}' -- ", http_response: resp)
          return nil
        end

        JSON.parse(resp.body)
      rescue JSON::ParserError => e
        log_error(method: "RDAMSC API query - path: '#{path}' -- ", error: e)
        nil
      end

      # rubocop:disable Metrics/AbcSize
      def process_scheme_entries(json:)
        return false unless json.is_a?(Hash)

        json = json.with_indifferent_access
        return false unless json['data'].present? && json['data'].fetch('items', []).any?

        json['data']['items'].each do |item|
          standard = MetadataStandard.find_or_create_by(uri: item['uri'], title: item['title'])
          standard.update(description: item['description'], locations: item['locations'],
                          related_entities: item['relatedEntities'], rdamsc_id: item['mscid'])
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
