# frozen_string_literal: true

require "nokogiri"

module ExternalApis

  # This service provides an interface to the OpenAire API.
  class OpenAireService < BaseService

    class << self

      # Retrieve the config settings from the initializer
      def api_base_url
        Rails.configuration.x.open_aire&.api_base_url || super
      end

      def active?
        Rails.configuration.x.open_aire&.active || super
      end

      def search_path
        Rails.configuration.x.open_aire&.search_path || super
      end

      def default_funder
        Rails.configuration.x.open_aire&.default_funder
      end

      # Search the OpenAire API for the specified Funder OR the Default Funder
      # rubocop:disable Metrics/MethodLength
      def search(funder: default_funder)
        target = "#{api_base_url}#{search_path % funder}"
        hdrs = {
          "Accept": "application/xml",
          "Content-Type": "*/*"
        }
        resp = http_get(uri: target, additional_headers: hdrs, debug: false)

        unless resp.code == 200
          handle_http_failure(method: "OpenAire search", http_response: resp)
          return []
        end
        parse_xml(xml: resp.body)
      end
      # rubocop:enable Metrics/MethodLength

      private

      # Process the XML response and convert each result into a ResearchProject
      def parse_xml(xml:)
        return [] unless xml.present?

        Nokogiri::XML(xml).xpath("//pair/displayed-value").map do |node|
          parts = node.content.split("-")
          grant_id = parts.shift.to_s.strip
          description = parts.join(" - ").strip
          ResearchProject.new(grant_id, description)
        end
      # If a JSON parse error occurs then return results of a local table search
      rescue Nokogiri::XML::SyntaxError => e
        log_error(method: "OpenAire search", error: e)
        []
      end

    end

  end

end
