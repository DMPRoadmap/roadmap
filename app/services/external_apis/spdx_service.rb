# frozen_string_literal: true

module ExternalApis

  # This service provides an interface to the SPDX License List
  # For more information: https://spdx.org/licenses/index.html
  class SpdxService < BaseService

    class << self

      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.spdx&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.spdx&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.spdx&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.spdx&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.spdx&.max_redirects || super
      end

      def active?
        Rails.configuration.x.spdx&.active || super
      end

      def list_path
        Rails.configuration.x.spdx&.list_path
      end

      # Retrieves the full list of license from the SPDX Github repository.
      # For example:
      #   "licenses": [
      #     {
      #       "reference": "./0BSD.html",
      #       "isDeprecatedLicenseId": false,
      #       "detailsUrl": "http://spdx.org/licenses/0BSD.json",
      #       "referenceNumber": "67",
      #       "name": "BSD Zero Clause License",
      #       "licenseId": "0BSD",
      #       "seeAlso": [
      #         "http://landley.net/toybox/license.html"
      #       ],
      #       "isOsiApproved": true
      #     }
      #  ]
      def fetch
        licenses = query_spdx
        return [] unless licenses.present?

        licenses.each { |license| process_license(hash: license) }
        License.all
      end

      private

      # Queries the re3data API for the full list of repositories
      def query_spdx
        # Call the ROR API and log any errors
        resp = http_get(uri: "#{api_base_url}#{list_path}", additional_headers: {}, debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: "SPDX list", http_response: resp)
          return nil
        end
        json = JSON.parse(resp.body)
        return [] unless json.fetch("licenses", []).any?

        json["licenses"]
      rescue JSON::ParserError => e
        log_error(method: "SPDX search", error: e)
        []
      end

      # Updates or Creates a repository based on the XML input
      def process_license(hash:)
        return nil unless hash.present?

        license = License.find_or_initialize_by(identifier: hash["licenseId"])
        return nil unless license.present?

        license.update(
          name: hash["name"],
          url: hash["detailsUrl"],
          osi_approved: hash["isOsiApproved"],
          deprecated: hash["isDeprecatedLicenseId"]
        )
      end

    end

  end

end
