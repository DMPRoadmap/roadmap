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
      def fetch
        xml_list = query_re3data
        return [] unless xml_list.present?
        
        active_repo_ids = []
        xml_list.xpath('/list/repository').each do |repo_node|

          repo_id = repo_node.xpath('./id').text.strip
          if repo_id.present?
            # Fetch additional data for the repository
            xml = query_re3data_repository(repo_id: repo_id)
            
            # Only process repositories that don't have an endDate node i.e. active 
            if xml.xpath('.//r3d:endDate', 'r3d' => 'http://www.re3data.org/schema/2-2').empty?
              process_repository(id: repo_id, node: xml.xpath('//r3d:re3data//r3d:repository').first)
              
              # Add repository ID to list of active repositories
              active_repo_ids << repo_id 
            end       
          end
        end
        
        clear_inactive_repositories(active_repo_ids)
      end
      
      private

      # Method to clear repositories that were not identified as active
      def clear_inactive_repositories(active_ids)
        Repository.where.not(uri: active_ids).destroy_all
      end

      # Queries the re3data API for the full list of repositories
      def query_re3data
        # Call the ROR API and log any errors
        resp = http_get(uri: "#{api_base_url}#{list_path}", additional_headers: {},
                        debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 're3data list', http_response: resp)
          return nil
        end
        Nokogiri.XML(resp.body, nil, 'utf8')
      end

      # Queries the re3data API for the specified repository
      def query_re3data_repository(repo_id:)
        return [] unless repo_id.present?

        target = "#{api_base_url}#{repository_path}#{repo_id}"
        # Call the ROR API and log any errors
        resp = http_get(uri: target, additional_headers: {},
                        debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: "re3data repository #{repo_id}", http_response: resp)
          return []
        end
        Nokogiri.XML(resp.body, nil, 'utf8')
      end

      # Updates or Creates a repository based on the XML input
      def process_repository(id:, node:)
        return nil unless id.present? && node.present?

        # Try to find the Repo by the re3data identifier
        repo = Repository.find_by(uri: id)
        homepage = node.xpath('//r3d:repositoryURL')&.text
        name = node.xpath('//r3d:repositoryName')&.text
        repo = Repository.find_by(homepage: homepage) unless repo.present?
        repo = Repository.find_or_initialize_by(uri: id, name: name) unless repo.present?
        repo = parse_repository(repo: repo, node: node)
        repo.reload
      end

      # Updates the Repository based on the XML input
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def parse_repository(repo:, node:)
        return nil unless repo.present? && node.present?

        repo.update(
          description: node.xpath('//r3d:description')&.text,
          homepage: node.xpath('//r3d:repositoryURL')&.text,
          contact: node.xpath('//r3d:repositoryContact')&.text,
          info: {
            types: node.xpath('//r3d:type').map(&:text),
            subjects: node.xpath('//r3d:subject').map(&:text),
            provider_types: node.xpath('//r3d:providerType').map(&:text),
            keywords: node.xpath('//r3d:keyword').map(&:text),
            access: node.xpath('//r3d:databaseAccess//r3d:databaseAccessType')&.text,
            pid_system: node.xpath('//r3d:pidSystem')&.text,
            policies: node.xpath('//r3d:policy').map { |n| parse_policy(node: n) },
            upload_types: node.xpath('//r3d:dataUpload').map { |n| parse_upload(node: n) }
          }
        )
        repo
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def parse_policy(node:)
        return nil unless node.present?

        {
          name: node.xpath('r3d:policyName')&.text,
          url: node.xpath('r3d:policyURL')&.text
        }
      end

      def parse_upload(node:)
        return nil unless node.present?

        {
          type: node.xpath('r3d:dataUploadType')&.text,
          restriction: node.xpath('r3d:dataUploadRestriction')&.text
        }
      end
    end
  end
end
