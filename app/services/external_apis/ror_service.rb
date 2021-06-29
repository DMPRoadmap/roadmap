# frozen_string_literal: true

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

      def full_catalog_file
        Rails.configuration.x.ror&.full_catalog_file
      end

      def catalog_process_date
        Rails.configuration.x.ror&.catalog_process_date
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

      def fetch(force: false)
        # TODO: At some point find a way to retrieve the latest zip file
        #       They are current stored as zip files within the GitHub repo:
        #       https://github.com/ror-community/ror-api/tree/master/rorapi/data
        #
        # TODO: Write the downloaded json file to the tmp/ dir
        file = File.new(full_catalog_file, "r")
        mod_date = file.mtime
        # Create the timestamp file if it is not present
        ror_tstamp = File.open(catalog_process_date, "w+") unless File.exist?(catalog_process_date) && !force
        ror_tstamp = File.open(catalog_process_date, "r+") unless ror_tstamp.present?
        last_proc_date = ror_tstamp.read

        method = "ExternalApis::RorService.fetch(force: #{force.to_s})"

        if file.present?
          if mod_date.to_s == last_proc_date
            log_message(method: method, message: "ROR file already processed: #{mod_date.to_s}")
          else
            log_message(method: method, message: "ROR proccessing new file: #{mod_date.to_s}")
            if process_ror_file(file: file, time: mod_date)
              f = File.open(catalog_process_date, "w")
              f.write(mod_date.to_s)
            else
              log_error(method: method, error: StandardError.new("An error occurred while processing the file!"))
            end
          end
        end
      end

      private

      # Parse the JSON file and process each individual record
      def process_ror_file(file:, time:)
        return false unless file.present?

        method = "ExternalApis::RorService.process_ror-file(file: #{file}, time: #{time}"
        json = JSON.parse(file.read)
        cntr = 0
        total = json.length
        json.each do |hash|
          cntr += 1
          log_message(method: method, message: "Processed #{cntr} out of #{total} records") if cntr % 1000 == 0

          unless process_ror_record(record: hash, time: time)
            log_message(
              method: method,
              message: "Unable to process record for: '#{hash&.fetch("name", "unknown")}'",
              info: false
            )
          end
        end
        # Remove any old ROR records (their file_timestamps would not have been updated)
        # Note this does not remove any associated Org records!
        OrgIndex.where("file_timestamp < ?", time.strftime('%Y-%m-%d %H:%M:%S')).destroy_all
        true
      rescue JSON::ParserError => e
        log_error(method: method, error: e)
        false
      end

      # Transfer the contents of the JSON record to the org_indices table
      def process_ror_record(record:, time:)
        return nil unless record.present? && record.is_a?(Hash) && record["id"].present?

        org_index = OrgIndex.find_or_create_by(ror_id: record["id"])

        # If its already associated with an Org don't change the name!
        org_index.name = safe_string(value: org_name(item: record)) unless org_index.org_id.present?

        # Update the rest of the info
        org_index.acronyms = record["acronyms"]
        org_index.aliases = record["aliases"]
        org_index.country = record["country"]
        org_index.types = record["types"]
        org_index.language = org_language(item: record)
        org_index.file_timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        org_index.fundref_id = fundref_id(item: record)
        org_index.home_page = safe_string(value: record.fetch("links", []).first)

        # TODO: We should create some sort of Super Admin page to highlight unmapped
        #       OrgIndex records so that they can be connected to their Org

        org_index.save
        true
      rescue StandardError => e
        log_error(method: "ExternalApis::RorService.process_ror_record", error: e)
        log_message(method: "ExternalApis::RorService.process_ror-record", message: record.to_s)
        false
      end

      def safe_string(value:)
        return value if value.blank? || value.length < 255

        value[0..254]
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
