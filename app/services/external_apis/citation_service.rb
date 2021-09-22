# frozen_string_literal: true

require 'base64'

module ExternalApis

  # This service provides an interface to Datacite API.
  class CitationService < BaseService

    class << self

      def api_base_url
        Rails.configuration.x.datacite_citation&.api_base_url
      end

      def active
        Rails.configuration.x.datacite_citation&.active
      end

      # Create a new DOI
      # rubocop:disable Metrics/CyclomaticComplexity
      def fetch(id:)
        return nil unless active && id.present? && id.is_a?(RelatedIdentifier)

p "URI: #{id_to_uri(id: id.value)}"

        resp = http_get(uri: id_to_uri(id: id.value)) # , debug: true)

p resp.code
pp resp.body

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'CitationService fetch', http_response: resp)
          return nil
        end

        json = JSON.parse(resp.body)
        process_json(doi: id.value, json: json)
      rescue JSON::ParserError => e
        log_error(method: 'CitationService fetch JSON parse error', error: e)
        nil
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      def id_to_uri(id:)
        return nil unless id.present?

        id.start_with?('http') ? id : "#{api_base_url}/#{id}"
      end

      # Convert the EZID response into identifiers
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def process_json(doi:, json:)
        return doi unless json.present? && json['DOI'].present? &&
                          json.fetch('author', []).any? && json['title'].present? &&
                          json['type'].present? && json['publisher'].present?

        year = detect_publication_year(json: json)
        return doi unless year.present?

        authors = json['author'].map { |author| "#{author['family']}, #{author['given'][0]}." }.join(', ')
        link = "<a href=\"#{doi}\" target=\"_blank\">#{doi}</a>"

        "#{authors} (#{year}). \"#{json['title']}\" [#{json['type'].capitalize}]. In #{json['publisher']}. #{link}"
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Dates are painful and come in this format:
      #   "published-print": { "date-parts": [[2013, 4, 23]] }
      def detect_publication_year(json:)
        year = find_year(hash: json['published-print'])
        year = find_year(hash: json['deposited']) unless year.present?
        year = find_year(hash: json['indexed']) unless year.present?
        year = find_year(hash: json['content-created']) unless year.present?
        year = find_year(hash: json['issued']) unless year.present?
        year = find_year(hash: json['created']) unless year.present?
        year
      end

      def find_year(hash:)
        return nil unless hash.present? && hash['date-parts'].present?

        parts = hash.fetch('date-parts', [[]])
        return nil unless parts[0].present?

        parts[0][0]
      end

    end

  end

end
