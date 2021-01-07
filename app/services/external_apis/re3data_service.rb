# frozen_string_literal: true

module ExternalApis

  # This service provides an interface to the Registry of Research Data
  # Repositories (re3data.org) API.
  # For more information: https://www.re3data.org/api/doc
  class Re3dataService < BaseService

    class << self

      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.re3data&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.re3data&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.re3data&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.re3data&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.re3data&.max_redirects || super
      end

      def active?
        Rails.configuration.x.re3data&.active || super
      end

      def list_path
        Rails.configuration.x.re3data&.list_path
      end

      def repository_path
        Rails.configuration.x.re3data&.repository_path
      end

      # Retrieves the full list of repositories from the re3data API as XML.
      # For example:
      #   <list>
      #     <repository>
      #       <id>r3d100000001</id>
      #       <name>Odum Institute Archive Dataverse</name>
      #       <link href="/api/v1/repository/r3d100000001" rel="self"/>
      #     </repository>
      #   </list>
      def fetch_list
        xml_list = query_re3data
        return [] unless xml_list.present?

        xml_list.xpath("/list/repository/id").map do |node|

p node.text

          parse_results(xml: query_re3data_repository(repo_id: node.text))
break
        end
      end

      # Search the preloaded list of repositories
      # @return an Array of Hashes:
      # {
      #   id: 'https://ror.org/12345',
      #   name: 'Sample University (sample.edu)',
      #   sort_name: 'Sample University',
      #   score: 0
      #   weight: 0
      # }
      def search(term:, filters: [])
        return [] unless active? && term.present? && ping

        process_pages(
          term: term,
          json: query_ror(term: term, filters: filters),
          filters: filters
        )

      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: "ROR search", error: e)
        []
      end

      private

      # Queries the re3data API for the full list of repositories
      def query_re3data
        # Call the ROR API and log any errors
        resp = http_get(uri: "#{api_base_url}#{list_path}", additional_headers: {},
                        debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: "re3data list", http_response: resp)
          nil
        end
        Nokogiri.XML(resp.body, nil, "utf8")
      end

      # Queries the re3data API for the specified repository
      def query_re3data_repository(repo_id:)
        return [] unless repo_id.present?

        target = "#{api_base_url}#{repository_path}#{repo_id}"

        # Call the ROR API and log any errors
        resp = http_get(uri: target, additional_headers: {},
                        debug: false)

p resp.body

        unless resp.present? && resp.code == 200
          handle_http_failure(method: "re3data repository #{repo_id}", http_response: resp)
          return []
        end
        Nokogiri.XML(resp.body, nil, "utf8")
      end

      # Convert the JSON items into a hash
      def parse_results(xml:)
        results = []
        return results unless xml.present?

        repository = xml.xpath("/r3d:repository")

        {
          id: repository.xpath("r3d:re3data.orgIdentifier")&.text,
          name: repository.xpath("r3d:repositoryName")&.text
        }
      end

      # Org names are not unique, so include the Org URL if available or
      # the country. For example:
      #    "Example College (example.edu)"
      #    "Example College (Brazil)"
      def org_name(item:)
        return "" unless item.present? && item["name"].present?

        country = item.fetch("country", {}).fetch("country_name", "")
        website = org_website(item: item)
        # If no website or country then just return the name
        return item["name"] unless website.present? || country.present?

        # Otherwise return the contextualized name
        "#{item['name']} (#{website || country})"
      end

      # Extracts the org's ISO639 if available
      def org_language(item:)
        dflt = I18n.default_locale || "en"
        return dflt unless item.present?

        labels = item.fetch("labels", [{ "iso639": dflt }])
        labels.first&.fetch("iso639", I18n.default_locale) || dflt
      end

      # Extracts the website domain from the item
      def org_website(item:)
        return nil unless item.present? && item.fetch("links", [])&.any?
        return nil if item["links"].first.blank?

        # A website was found, so extract just the domain without the www
        domain_regex = %r{^(?:http://|www\.|https://)([^/]+)}
        website = item["links"].first.scan(domain_regex).last.first
        website.gsub("www.", "")
      end

      # Extracts the FundRef Id if available
      def fundref_id(item:)
        return "" unless item.present? && item["external_ids"].present?
        return "" unless item["external_ids"].fetch("FundRef", {}).any?

        # If a preferred Id was specified then use it
        ret = item["external_ids"].fetch("FundRef", {}).fetch("preferred", "")
        return ret if ret.present?

        # Otherwise take the first one listed
        item["external_ids"].fetch("FundRef", {}).fetch("all", []).first
      end

    end

  end

end
