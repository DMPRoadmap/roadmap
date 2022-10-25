# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to a DMPHub system: https://github.com/CDLUC3/dmphub.
  class DmphubService < BaseDmpIdService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.dmphub&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.dmphub&.api_base_url || super
      end

      def active?
        Rails.configuration.x.dmphub&.active || super
      end

      def name
        Rails.configuration.x.dmphub&.name
      end

      def description
        Rails.configuration.x.dmphub&.description
      end

      def client_id
        Rails.configuration.x.dmphub&.client_id
      end

      def client_secret
        Rails.configuration.x.dmphub&.client_secret
      end

      def auth_path
        Rails.configuration.x.dmphub&.auth_path
      end

      def mint_path
        Rails.configuration.x.dmphub&.mint_path
      end

      def update_path
        Rails.configuration.x.dmphub&.update_path
      end

      def delete_path
        Rails.configuration.x.dmphub&.delete_path
      end

      def caller_name
        ApplicationService.application_name.split('-').first.to_sym
      end

      def api_client
        ApiClient.find_by(name: name.gsub('Service', '').downcase)
      end

      def callback_path
        Rails.configuration.x.dmphub&.callback_path || super
      end

      def callback_method
        Rails.configuration.x.dmphub&.callback_method&.downcase&.to_sym || super
      end

      # Create a new DMP ID
      # rubocop:disable Metrics/AbcSize
      def mint_dmp_id(plan:)
        return nil unless active? && auth && plan.present?

        hdrs = {
          Authorization: @token,
          'Server-Agent': "#{caller_name} (#{client_id})"
        }
        resp = http_post(uri: "#{api_base_url}#{mint_path}",
                         additional_headers: hdrs, debug: false,
                         data: json_from_template(plan: plan))

        # DMPHub returns a 201 (created) when a new DMP ID has been minted or
        #                a 405 (method_not_allowed) when a DMP ID already exists
        unless resp.present? && [201, 405].include?(resp.code)
          handle_http_failure(method: 'DMPHub mint_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return nil
        end

        dmp_id = process_response(response: resp)
        add_subscription(plan: plan, dmp_id: dmp_id) if dmp_id.present?
        dmp_id
      end
      # rubocop:enable Metrics/AbcSize

      # Update the DMP ID
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def update_dmp_id(plan:)
        return nil unless active? && auth && plan.present?

        hdrs = {
          Authorization: @token,
          'Server-Agent': "#{caller_name} (#{client_id})"
        }

        target = format("#{api_base_url}#{callback_path}", dmp_id: plan.dmp_id&.value_without_scheme_prefix)
        resp = http_put(uri: target, additional_headers: hdrs, debug: false,
                        data: json_from_template(plan: plan))

        # DMPHub returns a 200 when successful
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'DMPHub update_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return nil
        end

        dmp_id = process_response(response: resp)
        update_subscription(plan: plan) if dmp_id.present?
        dmp_id
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      # Delete the DMP ID
      def delete_dmp_id(plan:)
        return nil unless active? && plan.present?

        # implement this later once the DMPHub supports it
        plan.present?
      end

      # Register the ApiClient behind the minter service as a Subscriber to the Plan
      # if the service has a callback URL and ApiClient
      def add_subscription(plan:, dmp_id:)
        client = api_client
        path = callback_path
        Rails.logger.warn 'DMPHubService - No ApiClient defined!' if client.blank?
        return nil unless plan.present? &&
                          dmp_id.present? &&
                          path.present? &&
                          client.present?

        Subscription.create(
          plan: plan,
          subscriber: client,
          callback_uri: format(path, dmp_id: dmp_id.gsub(%r{https?://doi.org/}, '')),
          updates: true,
          deletions: true,
          last_notified: Time.zone.now
        )
      end

      # Bump the last_notified timestamp on the subscription
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def update_subscription(plan:)
        client = api_client
        Rails.logger.warn 'DMPHubService - No ApiClient defined!' if client.blank?
        return false unless plan.present? &&
                            plan.dmp_id.present? &&
                            callback_path.present? &&
                            client.present?

        subscriptions = plan.subscriptions.select do |sub|
          sub.subscriber == client && sub.updates?
        end
        return false unless subscriptions.any?

        subscriptions.each { |sub| sub.update(last_notified: Time.zone.now) }
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      attr_accessor :token

      # Authenticate with the DMPHub
      def auth
        data = {
          grant_type: 'client_credentials',
          client_id: client_id,
          client_secret: client_secret
        }

        resp = http_post(uri: "#{api_base_url}#{auth_path}",
                         additional_headers: {}, data: data.to_json, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'DMPHub mint_dmp_id', http_response: resp)
          return nil
        end
        @token = process_token(json: resp.body)
        @token.present?
      end

      # Process the authentication response from DMPHub to retrieve the JWT
      def process_token(json:)
        hash = JSON.parse(json).with_indifferent_access
        return nil unless hash[:access_token].present? && hash[:token_type].present?

        "#{hash[:token_type]}: #{hash[:access_token]}"
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'DMPHub authentication', error: e)
        nil
      end

      # Prepare the DMP for transmission to the DMPHub (RDA Common Standard format)
      def json_from_template(plan:)
        payload = ActionController::Base.new.render_to_string(
          partial: '/api/v2/plans/show', locals: { plan: plan, client: api_client }
        )

        { dmp: JSON.parse(payload) }.to_json
      end

      # Extract the DMP ID from the response from the DMPHub
      def process_response(response:)
        hash = JSON.parse(response.body).with_indifferent_access
        return nil unless hash.fetch(:items, []).length == 1
        return nil if hash[:items].first[:dmp].blank?

        hash[:items].first[:dmp].fetch(:dmp_id, {})[:identifier]
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'DMPHub parse response: ', error: e)
        nil
      end
    end
  end
end
