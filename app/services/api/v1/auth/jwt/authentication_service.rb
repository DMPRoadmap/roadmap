# frozen_string_literal: true

module Api

  module V1

    module Auth

      module Jwt

        # This class provides Authentication for:
        #
        #   ApiClients (aka machines) with the following JSON body: {
        #     "grant_type": "client_credentials",
        #     "client_id": "[api_clients.client_id]",
        #     "client_secret": "[api_clients.client_secret]",
        #   }
        #
        #   Users with the following JSON body: {
        #     "grant_type": "authorization_code",
        #     "email": "[users.email]",
        #     "code": "[users.api_token]",
        #   }
        #
        class AuthenticationService

          attr_reader :errors
          attr_reader :expiration

          def initialize(json: {})
            json = json.nil? ? {} : json.with_indifferent_access
            type = json.fetch(:grant_type, "client_credentials")
            parse_client(json: json) if type == "client_credentials"
            parse_code(json: json) if type == "authorization_code"

            @errors = {}

            if @client_id.nil? || @client_secret.nil? ||
               !%w[client_credentials authorization_code].include?(type)
              @errors[:client_authentication] = _("Invalid grant type")
            end
          end

          # Returns the JWT if the authentication succeeds
          def call
            return nil unless @client_id.present? && @client_secret.present?

            obj = client
            return nil unless obj.present?

            # Fetch either the client_id or the email depending on whether we
            # are working with a ApiClient or a User
            id = obj.client_id if obj.is_a?(ApiClient)
            id = obj.email if obj.is_a?(User)
            return nil unless id.present?

            payload = { client_id: id }
            token = JsonWebToken.encode(payload: payload)
            # JWT appends the expiration directly to the incoming payload
            @expiration = payload[:exp]
            token
          end

          private

          attr_reader :client_id
          attr_reader :client_secret
          attr_reader :api_client
          attr_reader :auth_method

          # Returns the matching ApiClient if authentication succeeds
          def client
            return @api_client if @api_client.present?

            @api_client = send(:"#{@auth_method}")
            return @api_client if @api_client.present?

            # Record an error if no ApiClient or User was authenticated
            @errors[:client_authentication] = _("Invalid credentials")
            nil
          end

          # Tries to find an ApiClient that matches the :client_id. If found
          # it will attempt to authenticate the :client_secret
          def authenticate_client
            clients = ApiClient.where(client_id: @client_id)
            return nil unless clients.present? && clients.any?

            clnt = clients.first
            clnt.authenticate(secret: @client_secret) ? clnt : nil
          end

          # Tries to find a User whose email matches the :client_id. If found
          # it will attempt to authenticate the :api_token against the :client_secret
          def authenticate_user
            users = User.where("lower(email) LIKE lower(?)", @client_id)
            return nil unless users.present? && users.any?

            usr = users.first
            # Valid if User is active, has permission to use the API and
            # the :client_secret matches the token
            usr.active && usr.can_use_api? && usr.api_token == @client_secret ? usr : nil
          end

          # Handles ApiClient credentials
          def parse_client(json: {})
            @client_id = json.fetch(:client_id, nil)
            @client_secret = json.fetch(:client_secret, nil)
            @auth_method = "authenticate_client"
          end

          # Handles User credentials
          def parse_code(json: {})
            @client_id = json.fetch(:email, nil)
            @client_secret = json.fetch(:code, nil)
            @auth_method = "authenticate_user"
          end

        end

      end

    end

  end

end
