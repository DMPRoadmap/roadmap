# frozen_string_literal: true
require 'cgi'
require 'uri'

module MadmpExternalApis
  # This service provides an interface to Loterre API
  class LoterreService < ::ExternalApis::BaseService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.loterre&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.loterre&.api_base_url || super
      end

      def active?
        Rails.configuration.x.loterre&.active || super
      end

      def endpoints
        Rails.configuration.x.loterre&.endpoints
      end

      # Ping the Loterre API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active?

        resp = http_get(uri: api_base_url)
        resp.present? && resp.code == 200
      end

      # Use Loterre API
      def request(query_params: {}, params: {})
        return [] unless active?

        target = "#{api_base_url}/#{params&.dig(:path)}?#{URI.encode_www_form(query_params)}"

        resp = http_get(
          uri: target,
          additional_headers: {}
        )

        handle_failure(resp) unless resp.present? && [200, 201].include?(resp.code)

        resp
      end

      def handle_failure(resp)
        handle_http_failure(method: 'LoterreService query_builder', http_response: resp)
        nil
      end
    end
  end
end
