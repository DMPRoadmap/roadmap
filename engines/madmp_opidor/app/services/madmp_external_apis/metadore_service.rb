# frozen_string_literal: true
require 'uri'

module MadmpExternalApis
  # This service provides an interface to MetaDoRe API
  class MetadoreService < ::ExternalApis::BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.metadore&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.metadore&.api_base_url || super
      end

      def active?
        Rails.configuration.x.metadore&.active || super
      end

      def search_path
        Rails.configuration.x.metadore&.search_path || super
      end

      def size
        Rails.configuration.x.metadore&.size || super
      end

      def api_key
        Rails.configuration.x.metadore&.api_key || super
      end

      # Ping the MetaDoRe API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active?

        resp = http_get(uri: api_base_url)
        resp.present? && resp.code == 200
      end

      def search(query_params: {})
        return [] unless active?

        target = "#{api_base_url}#{search_path}?#{URI.encode_www_form(query_params)}"

        resp = http_get(
          uri: target,
          additional_headers: {
            'X-API-KEY': api_key,
            'Accept': 'application/json'
          }
        )

        handle_failure(resp) unless resp.present? && [200, 201].include?(resp.code)

        resp
      end

      def handle_failure(resp)
        handle_http_failure(method: 'MetaDoreService search', http_response: resp)
        nil
      end
    end
  end
end
