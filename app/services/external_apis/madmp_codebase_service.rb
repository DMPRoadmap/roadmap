# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to the OpenAire API.
  class MadmpCodebaseService < BaseService
    class << self
      # Retrieve the config settings from the initializer
      def api_base_url
        Rails.configuration.x.madmp_codebase&.api_base_url || super
      end

      def active?
        Rails.configuration.x.madmp_codebase&.active || super
      end

      def scripts_path
        Rails.configuration.x.madmp_codebase&.scripts_path
      end

      def run_path
        Rails.configuration.x.madmp_codebase&.run_path || super
      end

      # Ping the MadmpCodebase API to determine if it is online
      #
      # @return true/false
      def ping
        return true unless active?

        resp = http_get(uri: api_base_url)
        resp.present? && resp.code == 200
      end

      def scripts
        return [] unless active? && scripts_path.present?

        resp = http_get(uri: "#{api_base_url}#{scripts_path}")
        JSON.parse(resp.body)
      end

      def run(script_id, body: {})
        return nil unless active? && run_path.present? && script_id.present?

        target = "#{api_base_url}#{run_path % script_id}"

        resp = http_post(
          uri: target,
          additional_headers: {},
          data: body.to_json, debug: false
        )

        unless resp.present? && [200, 201].include?(resp.code)
          handle_http_failure(method: 'MadmpCodebase run', http_response: resp)
          return nil
        end
        JSON.parse(resp.body)
      end

      def project_search(project_id); end
    end
  end
end
