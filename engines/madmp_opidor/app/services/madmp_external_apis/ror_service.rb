# frozen_string_literal: true

module MadmpExternalApis
  # This service provides an interface to the Research Organization Registry (ROR)
  # API.
  # For more information: https://github.com/ror-community/ror-api
  class RorService < ::ExternalApis::BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.ror&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.ror&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.ror&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.ror&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.ror&.max_redirects || super
      end

      def active?
        Rails.configuration.x.ror&.active || super
      end

      def heartbeat_path
        Rails.configuration.x.ror&.heartbeat_path
      end

      def search_path
        Rails.configuration.x.ror&.search_path
      end

      # Ping the ROR API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active? && heartbeat_path.present?

        resp = http_get(uri: "#{api_base_url}#{heartbeat_path}")
        resp&.code == 200
      end

      # Search the ROR API for the given string.
      #
      # @return an Array of Hashes:
      # {
      #   id: 'https://ror.org/12345',
      #   name: 'Sample University (sample.edu)',
      #   sort_name: 'Sample University',
      #   score: 0
      #   weight: 0
      # }
      # The ROR limit appears to be 40 results (even with paging :/)
      def search(term:, filters: [])
        return [] unless active? && term.present? && ping

        process_pages(
          term:,
          json: query_ror(term:, filters:),
          filters:
        )

      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'ROR search', error: e)
        []
      end

      private

      # Queries the ROR API for the sepcified name and page
      def query_ror(term:, page: 1, filters: [])
        return [] unless term

        # Build the URL
        target = "#{api_base_url}#{search_path}"
        query = query_string(term:, page:, filters:)

        # Call the ROR API and log any errors
        resp = http_get(uri: "#{target}?#{query}", additional_headers: {}, debug: false)

        return [] unless resp&.code == 200

        JSON.parse(resp.body)
      rescue StandardError
        handle_http_failure(method: 'ROR search', http_response: resp)
        []
      end

      # Build the query string using the search term, current page and any
      # filters specified
      def query_string(term:, page: 1, filters: [])
        [
          "query=#{term}",
          "page=#{page}",
          ("filter=#{filters&.join(',')}" unless filters.nil?)
        ]&.compact&.join('&')
      end

      # Recursive method that can handle multiple ROR result pages if necessary
      # rubocop:disable Metrics/AbcSize
      def process_pages(term:, json:, filters: [])
        return [] if json.blank?

        results = parse_results(json:)
        num_of_results = json.fetch('number_of_results', 1).to_i

        # Determine if there are multiple pages of results
        pages = (num_of_results / max_results_per_page.to_f).to_f.ceil
        return results unless pages > 1

        # Gather the results from the additional page (only up to the max)
        (2..([pages, max_pages].min)).each do |page|
          json = query_ror(term:, page:, filters:)
          results += parse_results(json:)
        end
        results || []

      # If we encounter a JSON parse error on subsequent page requests then just
      # return what we have so far
      rescue JSON::ParserError => e
        log_error(method: 'ROR search', error: e)
        results || []
      end
      # rubocop:enable Metrics/AbcSize

      # Convert the JSON items into a hash
      # def parse_results(json:)
      #   results = []
      #   return results unless json.present? && json.fetch('items', []).any?

      #   json['items'].each do |item|
      #     next unless item['id'].present? && item['name'].present?

      #     results << {
      #       ror: item['id'].gsub(/^#{landing_page_url}/, ''),
      #       name: org_name(item: item),
      #       sort_name: item['name'],
      #       url: item.fetch('links', []).first,
      #       language: org_language(item: item),
      #       fundref: fundref_id(item: item),
      #       abbreviation: item.fetch('acronyms', []).first
      #     }
      #   end
      #   results
      # end

      # Convert the JSON items into a hash
      def parse_results(json:)
        return [] unless json['items']&.any?

        json['items']&.map do |item|
          {
            type: 'ROR',
            ror: get_ror_value(item:),
            name: get_name(item:),
            links: item&.dig('links' || []),
            country: get_country(item:),
            addresses: get_addresses(item:),
            acronyms: item.fetch('acronyms', []),
            external_ids: get_external_ids(item:)
          }
        end&.compact || []
      end

      def get_ror_value(item:)
        item['id'].to_s.gsub(/^#{landing_page_url}/, '') # Remove the 'landing_page_url' from the beginning of the 'id' value
      end

      def get_country(item:)
        {
          name: item.dig('country', 'country_name').to_s,
          code: item.dig('country', 'country_code').to_s
        }
      end

      def get_name(item:)
        return '' unless item&.dig('name') && item&.dig('country', 'country_code')

        country_code = item&.dig('country', 'country_code').to_s

        # Retrieve the 'labels' value from the 'item' hash, or assign an empty array if it's not present
        # Map the labels and create a new hash for each label, where 'iso639' is the key and 'label' is the value
        labels = item&.dig('labels')&.map { |label| { label['iso639'] || '' => label['label'].to_s } } || []

        # Create a new array containing a single hash with 'country_code' as the key, converted to lowercase,
        # and 'item['name']' as the value, then concatenate it with the 'labels' array
        [{ country_code.downcase => item['name'] }] + labels.compact
      end

      def get_addresses(item:)
        return [] unless item&.dig('addresses')

        item['addresses'].map do |address|
          {
            city: address['city'].to_s,
            department: address.dig('geonames_city', 'nuts_level3', 'name').to_s,
            area: address.dig('geonames_city', 'nuts_level2', 'name').to_s
          }
        end
      end

      def get_external_ids(item:)
        # Transform the values of the 'external_ids' hash by retrieving the 'all' attribute from each value
        item&.dig('external_ids')&.transform_values do |external_id|
          external_id['all'].is_a?(Array) ? external_id['all'] : [external_id['all']]
        end || {}
      end

      # Org names are not unique, so include the Org URL if available or
      # the country. For example:
      #    "Example College (example.edu)"
      #    "Example College (Brazil)"
      def org_name(item:)
        return '' unless item&.dig('name')

        country = item.dig('country', 'country_name').to_s
        website = org_website(item:)
        # If no website or country then just return the name
        return item['name'] unless website.present? || country.present?

        # Otherwise return the contextualized name
        "#{item['name']} (#{website || country})"
      end

      # Extracts the org's ISO639 if available
      def org_language(item:)
        dflt = I18n.default_locale || 'en'
        return dflt unless item&.fetch('labels', [])&.first&.fetch('iso639')

        item['labels'].first['iso639']
      end

      # Extracts the website domain from the item
      def org_website(item:)
        return nil unless item&.fetch('links', [])&.any?

        # A website was found, so extract just the domain without the www
        website = item['links'].first&.match(%r{^(?:http://|www\.|https://)([^/]+)})&.captures&.first
        website&.sub('www.', '')
      end

      # Extracts the FundRef Id if available
      def fundref_id(item:)
        return '' unless item&.fetch('external_ids', {})&.fetch('FundRef', [])&.any?

        # If a preferred Id was specified then use it
        preferred_id = item.dig('external_ids', 'FundRef', 'preferred')
        return preferred_id if preferred_id.present?

        # Otherwise take the first one listed
        item.dig('external_ids', 'FundRef', 'all')&.first.to_s
      end
    end
  end
end
