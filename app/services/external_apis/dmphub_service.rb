# frozen_string_literal: true

module ExternalApis

  # This service provides an interface to a DMPHub system: https://github.com/CDLUC3/dmphub.
  class DmphubService < BaseDoiService

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
        ApplicationService.application_name.split("-").first.to_sym
      end

      def api_client
        ApiClient.find_by(name: name.gsub("Service", "").downcase)
      end

      def callback_path
        Rails.configuration.x.dmphub&.callback_path || super
      end

      def callback_method
        Rails.configuration.x.dmphub&.callback_method&.downcase&.to_sym || super
      end

      # Create a new DOI
      def mint_doi(plan:)
        return nil unless active? && auth

        hdrs = {
          "Authorization": @token,
          "Server-Agent": "#{caller_name} (#{client_id})"
        }
        resp = http_post(uri: "#{api_base_url}#{mint_path}",
                         additional_headers: hdrs, debug: false,
                         data: json_from_template(plan: plan))

        # DMPHub returns a 201 (created) when a new DOI has been minted or
        #                a 405 (method_not_allowed) when a DOI already exists
        unless resp.present? && [201, 405].include?(resp.code)
          handle_http_failure(method: "DMPHub mint_doi", http_response: resp)
          return nil
        end

        doi = process_response(response: resp)
        add_subscription(plan: plan, doi: doi) if doi.present?
        doi
      end

      # Update the DOI
      def update_doi(plan:)
        return nil unless active? && auth && plan.present?

        hdrs = {
          "Authorization": @token,
          "Server-Agent": "#{caller_name} (#{client_id})"
        }

        target = "#{api_base_url}#{callback_path}" % { dmp_id: plan.doi.value_without_scheme_prefix }
        resp = http_put(uri: target, additional_headers: hdrs, debug: true,
                        data: json_from_template(plan: plan))

        # DMPHub returns a 200 when successful
        unless resp.present? && resp.code == 200
          handle_http_failure(method: "DMPHub update_doi", http_response: resp)
          return nil
        end

        doi = process_response(response: resp)
        update_subscription(plan: plan, doi: doi) if doi.present?
        doi
      end

      # Delete the DOI
      def delete_doi(plan:)
        return nil unless active? && plan.present?

        # implement this later if necessary and if reasonable. Is deleting a DOI feasible?
        plan.present?
      end

      # Register the ApiClient behind the minter service as a Subscriber to the Plan
      # if the service has a callback URL and ApiClient
      def add_subscription(plan:, doi:)
        Rails.logger.warn "DMPHubService - No ApiClient available for 'dmphub'!" unless api_client.present?
        return plan unless plan.present? && doi.present? &&
                           callback_path.present? && api_client.present?

        Subscription.create(
          plan: plan,
          subscriber: api_client,
          callback_uri: callback_path % { dmp_id: doi.gsub(/https?:\/\/doi.org\//, "") },
          updates: true,
          deletions: true
        )
      end

      # Bump the last_notified timestamp on the subscription
      def update_subscription(plan:, doi:)
        Rails.logger.warn "DMPHubService - No ApiClient available for 'dmphub'!" unless api_client.present?
        return plan unless plan.present? && doi.present? && callback_path.present? && api_client.present?

        Subscription.where(plan: plan, subscriber: api_client).update(last_notified: Time.now)
      end

      private

      attr_accessor :token

      # Authenticate with the DMPHub
      def auth
        data = {
          grant_type: "client_credentials",
          client_id: client_id,
          client_secret: client_secret
        }
        resp = http_post(uri: "#{api_base_url}#{auth_path}",
                         additional_headers: {}, data: data.to_json, debug: false)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: "DMPHub mint_doi", http_response: resp)
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
        log_error(method: "DMPHub authentication", error: e)
        nil
      end

      # Prepare the DMP for transmission to the DMPHub (RDA Common Standard format)
      def json_from_template(plan:)
        payload = ActionController::Base.new.render_to_string(
          partial: "/api/v1/plans/show", locals: { plan: plan }
        )

        { dmp: JSON.parse(payload) }.to_json
      end

      # Extract the DOI from the response from the DMPHub
      def process_response(response:)
        hash = JSON.parse(response.body).with_indifferent_access
        return nil unless hash.fetch(:items, []).length == 1
        return nil unless hash[:items].first[:dmp].present?

        hash[:items].first[:dmp].fetch(:dmp_id, {})[:identifier]
      # If a JSON parse error occurs then return results of a local table search
      rescue JSON::ParserError => e
        log_error(method: "DMPHub parse response: ", error: e)
        nil
      end

    end

  end

end
