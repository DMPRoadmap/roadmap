# frozen_string_literal: true

require 'digest'

module ExternalApis
  # This service provides an interface to the Research Organization Registry (ROR)
  # API.
  # For more information: https://github.com/ror-community/ror-api
  class RorService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.ror&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.ror&.api_base_url || super
      end

      def download_url
        Rails.configuration.x.ror&.download_url
      end

      def full_catalog_file
        Rails.configuration.x.ror&.full_catalog_file
      end

      def file_dir
        Rails.configuration.x.ror&.file_dir
      end

      def checksum_file
        Rails.configuration.x.ror&.checksum_file
      end

      def zip_file
        Rails.configuration.x.ror&.zip_file
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

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def fetch(force: false)
        method = "ExternalApis::RorService.fetch(force: #{force})"

        # Fetch the Zenodo metadata for ROR to see if we have the latest data dump
        metadata = fetch_zenodo_metadata

        if metadata.present?
          FileUtils.mkdir_p(file_dir)

          checksum = File.open(checksum_file, 'w+') unless File.exist?(checksum_file) && !force
          checksum = File.open(checksum_file, 'r+') if checksum.blank?
          old_checksum_val = checksum.read

          if old_checksum_val == metadata[:checksum]
            log_message(method: method, message: 'There is no new ROR file to process.')
          else
            download_file = metadata.fetch(:links, {})[:download]
            log_message(method: method, message: "New ROR file detected - checksum #{metadata[:checksum]}")
            log_message(method: method, message: "Downloading #{download_file}")

            payload = download_ror_file(url: metadata.fetch(:links, {})[:download])
            if payload.present?
              file = File.open(zip_file, 'wb')
              file.write(payload)

              # rubocop:disable Metrics/BlockNesting
              if validate_downloaded_file(file_path: zip_file, checksum: metadata[:checksum])
                json_file = download_file.split('/').last.gsub('.zip', '')
                json_file = "#{json_file}.json" unless json_file.end_with?('.json')

                # Process the ROR JSON
                if process_ror_file(zip_file: zip_file, file: json_file)
                  checksum = File.open(checksum_file, 'w')
                  checksum.write(metadata[:checksum])
                end
              else
                log_error(method: method, error: StandardError.new('Downloaded ROR zip does not match checksum!'))
              end
              # rubocop:enable Metrics/BlockNesting
            else
              log_error(method: method, error: StandardError.new('Unable to download ROR file!'))
            end
          end
        else
          log_error(method: method, error: StandardError.new('Unable to fetch ROR metadata from Zenodo!'))
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      # Fetch the latest Zenodo metadata for ROR files
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def fetch_zenodo_metadata
        Rails.logger.error 'No :download_url defined for RorService!' if download_url.blank?
        return nil if download_url.blank?

        # Fetch the latest ROR metadata from Zenodo (the query will place the most recent
        # version 1st)
        resp = http_get(uri: download_url, additional_headers: { host: 'zenodo.org' }, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'Fetching ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end
        json = JSON.parse(resp.body)

        # Extract the most recent file's metadata
        file_metadata = json.fetch('hits', {}).fetch('hits', []).first&.fetch('files', [])&.last&.with_indifferent_access
        unless file_metadata.present? && file_metadata.fetch(:links, {})[:download].present?
          handle_http_failure(method: 'No file found in ROR metadata from Zenodo', http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end

        file_metadata
      rescue JSON::ParserError => e
        log_error(method: 'RorService', error: e)
        nil
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Download the latest ROR data
      def download_ror_file(url:)
        return nil if url.blank?

        headers = {
          host: 'zenodo.org',
          Accept: 'application/zip'
        }
        resp = http_get(uri: url, additional_headers: headers, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: "Fetching ROR file from Zenodo - #{url}", http_response: resp)
          notify_administrators(obj: 'RorService', response: resp)
          return nil
        end
        resp.body
      end

      # Parse the JSON file and process each individual record
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def process_ror_file(zip_file:, file:)
        return false unless zip_file.present? && file.present?

        if unzip_file(zip_file: zip_file, destination: file_dir)
          method = 'ExternalApis::RorService.process_ror-file'
          if File.exist?("#{file_dir}/#{file}")
            json_file = File.open("#{file_dir}/#{file}", 'r')
            json = JSON.parse(json_file.read)
            cntr = 0
            total = json.length
            json.each do |hash|
              cntr += 1
              log_message(method: method, message: "Processed #{cntr} out of #{total} records") if (cntr % 1000).zero?

              hash = hash.with_indifferent_access if hash.is_a?(Hash)

              next if process_ror_record(record: hash, time: json_file.mtime)

              log_message(
                method: method,
                message: "Unable to process record for: '#{hash&.fetch('name', 'unknown')}'",
                info: false
              )
            end
            # Remove any old ROR records (their file_timestamps would not have been updated)
            # Note this does not remove any associated Org records!
            RegistryOrg.where('file_timestamp < ?', json_file.mtime.strftime('%Y-%m-%d %H:%M:%S')).destroy_all
            true
          else
            log_error(method: method, error: StandardError.new('Unable to find json in zip!'))
            false
          end
        else
          log_error(method: method, error: StandardError.new('Unable to unzip contents of ROR file'))
          false
        end
      rescue JSON::ParserError => e
        log_error(method: method, error: e)
        false
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Transfer the contents of the JSON record to the org_indices table
      # rubocop:disable Metrics/AbcSize
      def process_ror_record(record:, time:)
        return nil unless record.present? && record.is_a?(Hash) && record['id'].present?

        registry_org = RegistryOrg.find_or_create_by(ror_id: record['id'])
        registry_org.name = safe_string(value: org_name(item: record))
        registry_org.acronyms = record['acronyms']
        registry_org.aliases = record['aliases']
        registry_org.country = record['country']
        registry_org.types = record['types']
        registry_org.language = org_language(item: record)
        registry_org.file_timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        registry_org.fundref_id = fundref_id(item: record)
        registry_org.home_page = safe_string(value: record.fetch('links', []).first)

        # Attempt to find a matching Org record
        registry_org.org_id = check_for_org_association(registry_org: registry_org)

        # TODO: We should create some sort of Super Admin page to highlight unmapped
        #       RegistryOrg records so that they can be connected to their Org
        registry_org.save
        true
      rescue StandardError => e
        log_error(method: 'ExternalApis::RorService.process_ror_record', error: e)
        log_message(method: 'ExternalApis::RorService.process_ror-record', message: record.to_s)
        false
      end
      # rubocop:enable Metrics/AbcSize

      def safe_string(value:)
        return value if value.blank? || value.length < 255

        value[0..254]
      end

      # Determine if there is a matching Org record in the DB if so, attach it
      def check_for_org_association(registry_org:)
        return registry_org.org&.id if registry_org.org.present?

        ror = Identifier.by_scheme_name('ror', 'Org')
                        .where(value: registry_org.ror_id)
                        .first
        return nil if ror.blank?

        ror.present? ? ror.identifiable_id : nil
      end

      # Org names are not unique, so include the Org URL if available or
      # the country. For example:
      #    "Example College (example.edu)"
      #    "Example College (Brazil)"
      def org_name(item:)
        return '' unless item.present? && item['name'].present?

        country = item.fetch('country', {}).fetch('country_name', '')
        website = org_website(item: item)
        # If no website or country then just return the name
        return item['name'] unless website.present? || country.present?

        # Otherwise return the contextualized name
        "#{item['name']} (#{website || country})"
      end

      # Extracts the org's ISO639 if available
      def org_language(item:)
        dflt = I18n.default_locale || 'en'
        return dflt if item.blank?

        country = item.fetch('country', {}).fetch('country_code', '')
        labels = case country
                 when 'US'
                   [{ iso639: 'en' }]
                 else
                   item.fetch('labels', [{ iso639: dflt }])
                 end
        labels.first&.fetch('iso639', I18n.default_locale) || dflt
      end

      # Extracts the website domain from the item
      def org_website(item:)
        return nil unless item.present? && item.fetch('links', [])&.any?
        return nil if item['links'].first.blank?

        # A website was found, so extract just the domain without the www
        domain_regex = %r{^(?:http://|www\.|https://)([^/]+)}
        website = item['links'].first.scan(domain_regex).last.first
        website.gsub('www.', '')
      end

      # Extracts the FundRef Id if available
      def fundref_id(item:)
        return '' unless item.present? && item['external_ids'].present?
        return '' unless item['external_ids'].fetch('FundRef', {}).any?

        # If a preferred Id was specified then use it
        ret = item['external_ids'].fetch('FundRef', {}).fetch('preferred', '')
        return ret if ret.present?

        # Otherwise take the first one listed
        item['external_ids'].fetch('FundRef', {}).fetch('all', []).first
      end
    end
  end
end
