# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to Datacite API.
  class DataciteService < BaseDmpIdService
    class << self
      def name
        Rails.configuration.x.datacite&.name
      end

      def description
        Rails.configuration.x.datacite&.description
      end

      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.datacite&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.datacite&.api_base_url || super
      end

      def max_pages
        Rails.configuration.x.datacite&.max_pages || super
      end

      def max_results_per_page
        Rails.configuration.x.datacite&.max_results_per_page || super
      end

      def max_redirects
        Rails.configuration.x.datacite&.max_redirects || super
      end

      def active?
        Rails.configuration.x.datacite&.active || super
      end

      def client_id
        Rails.configuration.x.datacite&.repository_id
      end

      def client_secret
        Rails.configuration.x.datacite&.password
      end

      def mint_path
        Rails.configuration.x.datacite&.mint_path
      end

      def update_path
        Rails.configuration.x.datacite&.update_path
      end

      def shoulder
        Rails.configuration.x.datacite&.shoulder
      end

      # The callback_path is the API endpoint to send updates to once the Plan has changed
      # or been versioned
      def callback_path
        Rails.configuration.x.datacite&.callback_path
      end

      # Create a new DMP ID
      # rubocop:disable Metrics/AbcSize
      def mint_dmp_id(plan:)
        return nil unless active?

        data = json_from_template(dmp: plan)

        resp = http_post(uri: "#{api_base_url}#{mint_path}",
                         additional_headers: { 'Content-Type': 'application/vnd.api+json' },
                         data: data, basic_auth: auth, debug: false)

        unless resp.present? && [200, 201].include?(resp.code)
          handle_http_failure(method: 'Datacite mint_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return nil
        end

        json = process_response(response: resp)
        return nil if json.blank?

        dmp_id = json.fetch('data', attributes: { doi: nil })
                     .fetch('attributes', { doi: nil })['doi']

        add_subscription(plan: plan, dmp_id: dmp_id) if dmp_id.present?
        dmp_id
      end
      # rubocop:enable Metrics/AbcSize

      # Update the DMP ID
      # rubocop:disable Metrics/AbcSize
      def update_dmp_id(plan:)
        return false unless active? && plan.present? && plan.dmp_id.present?

        data = json_from_template(dmp: plan)
        id = plan.dmp_id.value_without_scheme_prefix
        resp = http_put(uri: "#{api_base_url}#{update_path}#{id}",
                        additional_headers: { 'Content-Type': 'application/vnd.api+json' },
                        data: data, basic_auth: auth, debug: false)

        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'Datacite update_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return false
        end

        update_subscription(plan: plan)
      end
      # rubocop:enable Metrics/AbcSize

      # Register the ApiClient behind the minter service as a Subscriber to the Plan
      # if the service has a callback URL and ApiClient
      def add_subscription(plan:, dmp_id:)
        client = api_client
        path = callback_path
        Rails.logger.warn 'DataciteService - No ApiClient defined!' if client.blank?
        return nil unless plan.present? && dmp_id.present? && path.present? && client.present?

        Subscription.create(
          plan: plan,
          subscriber: client,
          callback_uri: format(path, dmp_id: dmp_id.gsub(%r{https?://doi.org/}, '')),
          updates: true,
          deletions: true
        )
      end

      # Update the subscriptions for the Plan and Datacite
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def update_subscription(plan:)
        client = api_client
        Rails.logger.warn 'DataciteService - No ApiClient defined!' if client.blank?
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

      # Delete the DMP ID
      def delete_dmp_id(plan:)
        return nil unless active? && plan.present?

        # implement this later if necessary and if reasonable. Is deleting a DMP ID feasible?
        plan.present?
      end

      private

      def auth
        {
          username: Rails.configuration.x.datacite.repository_id,
          password: Rails.configuration.x.datacite.password
        }
      end

      def json_from_template(dmp:)
        ActionController::Base.new.render_to_string(
          template: '/datacite/_minter',
          locals: { prefix: shoulder, data_management_plan: dmp }
        )
      end

      def process_response(response:)
        json = JSON.parse(response.body)
        unless json['data'].present? &&
               json['data']['attributes'].present? &&
               json['data']['attributes']['doi'].present?
          log_error(method: 'Datacite mint_dmp_id',
                    error: StandardError.new('Unexpected JSON format from Datacite!'))
          return nil
        end
        json
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: 'Datacite mint_dmp_id', error: e)
        nil
      end
    end
  end
end
