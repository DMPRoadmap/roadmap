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

        xml_list.xpath('/list/repository/id').each do |node|
          next unless node.present? && node.text.present?

          xml = query_re3data_repository(repo_id: node.text)
          next unless xml.present?

          process_repository(id: node.text, node: xml.xpath('//r3d:re3data//r3d:repository').first)
        end
      end

      private

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

      # Then run fetch service, and find 
      # Updates the Repository based on the XML input
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def parse_repository(repo:, node:)
        return nil unless repo.present? && node.present?
        ### Pending: move the mariadb? method out of model/application_record.rb?
        # if ActiveRecord::Base.connection.select_rows("SHOW VARIABLES LIKE \"%version%\";")[8][1].downcase.include? "maria"
          new_types = []
          if node.xpath('//r3d:type').present?
            node.xpath('//r3d:type').map(&:text).each do |t|
              new_types.push(t)
            end
          end
          
          # array of string
          new_subjects = []
          if node.xpath('//r3d:subject').present?
            node.xpath('//r3d:subject').map(&:text).each do |t|
              new_subjects.push(t)
            end
          end
          
          # array of string
          new_provider_types = []
          if node.xpath('//r3d:providerType').present?
            node.xpath('//r3d:providerType').map(&:text).each do |t|
              new_provider_types.push(t)
            end
          end
          
          # array of string
          new_keywords = []
          if node.xpath('//r3d:keyword').present?
            node.xpath('//r3d:keyword').map(&:text).each do |t|
              new_keywords.push(t)
            end
          end

          # array of string
          new_access = []
          if node.xpath('//r3d:databaseAccess//r3d:databaseAccessType').present?
            node.xpath('//r3d:databaseAccess//r3d:databaseAccessType').map(&:text).each do |t|
              new_keywords.push(t)
            end
          end
          
          # array of objects of string
          new_policies = []
          if node.xpath('//r3d:policy').present?
            node.xpath('//r3d:policy').map { |n| parse_policy(node: n) }.each do |t|
              new_policies.push(t.to_json)
            end
          end
          
          # array of objects of string
          new_upload_types = []
          if node.xpath('//r3d:dataUpload').present?
            node.xpath('//r3d:dataUpload').map { |n| parse_upload(node: n) }.each do |t|
              new_upload_types.push(t.to_json)
            end
          end
        
          # new_info = "{'types':" + new_types.to_s + "," +
          #   "'subjects':" + new_subjects.to_s + "," +
          #   "'access':" + new_access.to_s + "," +
          #   "'provider_types':" + new_provider_types.to_s + "," +
          #   "'keyword':" + new_keywords.to_s + "," + 
          #   "'policies':" + new_policies.to_s + "," +
          #   "'upload_types':" + new_upload_types.to_s + "," +
          #   "'pid_system':" + node.xpath('//r3d:pidSystem')&.text.to_s + "}"

          new_info = '{"types":' + new_types.to_s + ',' +
            '"subjects":' + new_subjects.to_s + ',' +
            '"access":' + new_access.to_s + ',' +
            '"provider_types":' + new_provider_types.to_s + ',' +
            '"keyword":' + new_keywords.to_s + ',' +
            '"policies":' + new_policies.to_s + ',' +
            '"upload_types":' + new_upload_types.to_s + ',' +
            '"pid_system":"' + node.xpath('//r3d:pidSystem')&.text.to_s + '"}'
          new_j = JSON.parse(new_info)
          p "%%%%%%new_info"
          puts new_info
          new_info = new_info.to_s
          # p "%%%%%%%%%%%%%%%%%%%"
          # p new_info_side
          # puts new_info_side

          # cannot do json directly or pass json
          # new_info = {
          #   'types': new_types.to_s,
          #   'subjects': new_subjects.to_s,
          #   'provider_types': new_provider_types.to_s,
          #   'keyword': new_keywords.to_s,
          #   'policies': new_policies.to_s,
          #   'upload_types': new_upload_types.to_s,
          #   'pid_system': node.xpath('//r3d:pidSystem')&.text.to_s
          # }.to_json

          # new_j = JSON.parse(new_info)
          # p new_j.class
          # p new_j

          #TEST DIRECT JSON -> remotely transferred to arrow
          new_j = {}
          new_j.merge!(types: new_types,
          subjects: new_subjects,
          access: new_access,
          provider_types: new_provider_types,
          keyword: new_keywords,
          policies: new_policies,
          upload_types: new_upload_types,
          pid_system: node.xpath('//r3d:pidSystem')&.text)

          new_j = new_j.with_indifferent_access
          p new_j.to_json.class
          p new_j.to_json

          # this is accepted by MySQL, but will be parsed to arrow format in rails
          accepted = "{\"types\":[\"disciplinary\",\"institutional\"],\"subjects\":[\"3 Natural Sciences\",\"34 Geosciences (including Geography)\"],\"provider_types\":[\"serviceProvider\"],\"keywords\":[\"atmospheric science\",\"biology\",\"ecology\",\"geology\",\"global changes\",\"global warming\",\"human dimensions of climate change\",\"human health\",\"hydrology\",\"oceanography\"],\"access\":\"open\",\"pid_system\":\"DOI\",\"policies\":[{\"name\":\"NASA web privacy policy and important notices\",\"url\":\"https://www.nasa.gov/about/highlights/HP_Privacy.html\"}],\"upload_types\":[{\"type\":\"restricted\",\"restriction\":\"registration\"}]}"

          repo.update!(
              :info=> new_j.to_json, #remote: direct string & direct to_json won't work
              :description=> node.xpath('//r3d:description')&.text,
              :homepage=> node.xpath('//r3d:repositoryURL')&.text,
              :contact=> node.xpath('//r3d:repositoryContact')&.text
          ) #no behavior. return true but not save to database
          #update_column will but throw MYSQL constraint error
          repo
      #   else
          # repo.update!(
          #   description: node.xpath('//r3d:description')&.text,
          #   homepage: node.xpath('//r3d:repositoryURL')&.text,
          #   contact: node.xpath('//r3d:repositoryContact')&.text,
          #   info: {
          #     types: node.xpath('//r3d:type').map(&:text),
          #     subjects: node.xpath('//r3d:subject').map(&:text),
          #     provider_types: node.xpath('//r3d:providerType').map(&:text),
          #     keywords: node.xpath('//r3d:keyword').map(&:text),
          #     access: node.xpath('//r3d:databaseAccess//r3d:databaseAccessType')&.text,
          #     pid_system: node.xpath('//r3d:pidSystem')&.text,
          #     policies: node.xpath('//r3d:policy').map { |n| parse_policy(node: n) },
          #     upload_types: node.xpath('//r3d:dataUpload').map { |n| parse_upload(node: n) }
          #   }
          # )
          # repo
      #  end
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
