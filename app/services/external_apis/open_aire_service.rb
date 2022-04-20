# frozen_string_literal: true

<<<<<<< HEAD
require "nokogiri"

module ExternalApis

  # This service provides an interface to the OpenAire API.
  class OpenAireService < BaseService

    class << self

=======
require 'nokogiri'

module ExternalApis
  # This service provides an interface to the OpenAire API.
  class OpenAireService < BaseService
    class << self
>>>>>>> upstream/master
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
      # Note this functions result gets cached by the ResearchProjectsController
      # ToDo: Evaluate for ActiveJob
      def search(funder: default_funder)
        return [] unless active?

        target = "#{api_base_url}#{search_path % funder}"
        hdrs = {
<<<<<<< HEAD
          "Accept": "application/xml",
          "Content-Type": "*/*"
=======
          Accept: 'application/xml',
          'Content-Type': '*/*'
>>>>>>> upstream/master
        }
        resp = http_get(uri: target, additional_headers: hdrs, debug: false)

        unless resp.code == 200
<<<<<<< HEAD
          handle_http_failure(method: "OpenAire search", http_response: resp)
=======
          handle_http_failure(method: 'OpenAire search', http_response: resp)
>>>>>>> upstream/master
          return []
        end
        parse_xml(xml: resp.body)
      end

      private

      # Process the XML response and convert each result into a ResearchProject
      def parse_xml(xml:)
        return [] unless xml.present?

<<<<<<< HEAD
        Nokogiri::XML(xml).xpath("//pair/displayed-value").map do |node|
          parts = node.content.split("-")
          grant_id = parts.shift.to_s.strip
          description = parts.join(" - ").strip
=======
        Nokogiri::XML(xml).xpath('//pair/displayed-value').map do |node|
          parts = node.content.split('-')
          grant_id = parts.shift.to_s.strip
          description = parts.join(' - ').strip
>>>>>>> upstream/master
          ResearchProject.new(grant_id, description)
        end
      # If a JSON parse error occurs then return results of a local table search
      rescue Nokogiri::XML::SyntaxError => e
<<<<<<< HEAD
        log_error(method: "OpenAire search", error: e)
        []
      end

    end

  end

=======
        log_error(method: 'OpenAire search', error: e)
        []
      end
    end
  end
>>>>>>> upstream/master
end
