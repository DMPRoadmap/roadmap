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

      def auth_url
        Rails.configuration.x.dmphub&.auth_url
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

      def token_path
        Rails.configuration.x.dmphub&.token_path
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

      def narrative_path
        Rails.configuration.x.dmphub&.narrative_path
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

      # Proxy a call to one of the funder API searches that resides in the DMPHub AWS based API Gateway
      def proxied_award_search(api_target:, args: {})
        authorized = auth
        notify_administrators(obj: api_target, response: 'Unable to authenticate with DMPHub!') unless authorized
        return [] unless api_target.is_a?(String) && args.is_a?(Hash) && args.values.any? && authorized

        query_string = args.keys.map { |key| "#{key}=#{args[key].to_s}" }.join('&')
        uri = URI("#{api_base_url}#{api_target}?#{query_string}")

        opts = {
          follow_redirects: true,
          limit: 3,
          headers: {
            'Authorization': @token,
            'Server-Agent': "#{caller_name} (#{client_id})",
            'Accept': 'application/json'
          }
        }
        # opts[:debug_output] = $stdout

        resp = HTTParty.get(uri, opts)
        unless resp.code == 200
          puts "DMPHub unable to search the API at #{uri.to_s} :: received a #{resp.code}"
          puts resp.body.inspect
          handle_http_failure(method: 'DMPHub proxied_award_search', http_response: resp)
          notify_administrators(obj: args, response: resp)
          return nil
        end

        JSON.parse(resp.body)['items']
      rescue StandardError => e
        puts "FATAL: #{e.message}"
        log_error(method: 'DmphubService.proxied_award_search', error: e)
      end

      # Create a new DMP ID
      # rubocop:disable Metrics/AbcSize
      def mint_dmp_id(plan:)
        # TODO: Add the auth check and header back in once Cognito is working!
        return nil unless active? && plan.present? && auth

        opts = {
          follow_redirects: true,
          limit: 6,
          headers: {
            'authorization': @token,
            'Server-Agent': "#{caller_name} (#{client_id})",
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: json_from_template(plan: plan)
        }
        # opts[:debug_output] = $stdout
        resp = HTTParty.post("#{api_base_url}#{mint_path}", opts)
        # puts "CALLED DMPHUB AND GOT:"
        # pp resp.body

        # DMPHub returns a 201 (created) when a new DMP ID has been minted or
        #                a 405 (method_not_allowed) when a DMP ID already exists
        unless resp.present? && [201, 405].include?(resp.code)
          puts "DMPHub unable to mint DMP ID: received a #{resp.code}"
          puts resp.body.inspect
          handle_http_failure(method: 'DMPHub mint_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return nil
        end

        dmp_id = process_response(response: resp)
        add_subscription(plan: plan, dmp_id: dmp_id) if dmp_id.present?
        dmp_id
      rescue StandardError => e
        puts "FATAL: #{e.message}"
        log_error(method: 'DmphubService.mint_dmp_id', error: e)
      end
      # rubocop:enable Metrics/AbcSize

      # Update the DMP ID
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      def update_dmp_id(plan:)
        # TODO: Add the auth check and header back in once Cognito is working!
        return nil unless active? && plan.present? && auth

        opts = {
          follow_redirects: true,
          limit: 6,
          headers: {
            'authorization': @token,
            'Server-Agent': "#{caller_name} (#{client_id})",
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: json_from_template(plan: plan)
        }
        # opts[:debug_output] = $stdout
        target = format("#{api_base_url}#{callback_path}", dmp_id: plan.dmp_id&.value_without_scheme_prefix)
        resp = HTTParty.put(target, opts)
        # puts "CALLED DMPHUB AND GOT:"
        # pp resp.body

        # DMPHub returns a 200 when successful
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'DMPHub update_dmp_id', http_response: resp)
          notify_administrators(obj: plan, response: resp)
          return nil
        end

        dmp_id = process_response(response: resp)
        plan.update()
        update_subscription(plan: plan) if dmp_id.present?
        dmp_id
      rescue StandardError => e
        puts "FATAL: #{e.message}"
        log_error(method: 'DmphubService.update_dmp_id', error: e)
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

      # Delete the DMP ID
      def delete_dmp_id(plan:)
         # TODO: Add the auth check and header back in once Cognito is working!
         return nil unless active? && plan.present? && auth

         hdrs = {
           #Authorization: @token,
           'Server-Agent': "#{caller_name} (#{client_id})"
         }

         target = format("#{api_base_url}#{callback_path}", dmp_id: plan.dmp_id&.value_without_scheme_prefix)
         payload = json_from_template(plan: plan)
         resp = http_delete(uri: target, additional_headers: hdrs, debug: false, data: payload)

         # DMPHub returns a 200 when successful
         unless resp.present? && resp.code == 200
           handle_http_failure(method: 'DMPHub delete_dmp_id', http_response: resp)
           notify_administrators(obj: plan, response: resp)
           return nil
         end

         dmp_id = process_response(response: resp)
         delete_subscription(plan: plan) if dmp_id.present?
         dmp_id
      rescue StandardError => e
        puts "FATAL: #{e.message}"
        log_error(method: 'DmphubService.delete_dmp_id', error: e)
      end

      # Submit the narrative PDF document to the DMPHub
      def post_narrative(wip:)
        return false unless wip.is_a?(Wip)

        hdrs = {
          'Authorization': @token,
          'Content-Type': 'multipart/form-data',
          'Server-Agent': "#{caller_name} (#{client_id})"
        }
        target = "#{api_base_url}#{narrative_path}"
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

      def delete_subscription(plan:)
        client = api_client
        Rails.logger.warn 'DMPHubService - No ApiClient defined!' if client.blank?
        return false unless plan.present? &&
                            plan.dmp_id.present? &&
                            callback_path.present? &&
                            client.present?

        subscriptions = plan.subscriptions.select do |sub|
          sub.subscriber == client && sub.deletions?
        end
        return false unless subscriptions.any?

        subscriptions.each(&:destroy)
        true
      end

      private

      attr_accessor :token

      # Authenticate with the DMPHub
      def auth
        scope_env = Rails.env.production? ? 'prd' : Rails.env.stage? ? 'stg' : 'dev'
        scopes = "#{auth_url}#{scope_env}.read #{auth_url}#{scope_env}.write"
        creds = Base64.strict_encode64("#{client_id}:#{client_secret}")

        opts = {
          follow_redirects: true,
          limit: 6,
          headers: {
            'authorization': "Basic #{creds}",
            'Server-Agent': "#{caller_name} (#{client_id})",
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json'
          },
          body: "grant_type=client_credentials&scope=#{scopes}",
          debug: true
        }
        # opts[:debug_output] = $stdout

        resp = HTTParty.post("#{auth_url}#{token_path}", opts)
        unless resp.present? && resp.code == 200
          handle_http_failure(method: 'DMPHub mint_dmp_id', http_response: resp)
          return nil
        end

        @token = process_token(json: resp.body)
        @token.present?
      end

      # Process the authentication response from DMPHub to retrieve the JWT
      def process_token(json:)
        hash = JSON.parse(json)
        return nil unless hash['access_token'].present?

        # "#{hash[:token_type]}: #{hash[:access_token]}"
        hash['access_token']
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
