# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    module Auth

      module Jwt

        class AuthorizationService

=======
  module V1
    module Auth
      module Jwt
        # Class to handle User authorization
        class AuthorizationService
>>>>>>> upstream/master
          def initialize(headers: {})
            @headers = headers.nil? ? {} : headers
            @errors = ActiveSupport::HashWithIndifferentAccess.new
          end

          def call
            client
          end

          attr_reader :errors

          private

          # Lookup the Client bassed on the client_id embedded in the JWT
<<<<<<< HEAD
=======
          # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
>>>>>>> upstream/master
          def client
            return @api_client if @api_client.present?

            token = decoded_auth_token
            # If the token is missing or invalid then set the client to nil
<<<<<<< HEAD
            errors[:token] = _("Invalid token") unless token.present?
=======
            errors[:token] = _('Invalid token') unless token.present?
>>>>>>> upstream/master
            @api_client = nil unless token.present? && token[:client_id].present?
            return @api_client unless token.present? && token[:client_id].present?

            @api_client = ApiClient.where(client_id: token[:client_id]).first
            return @api_client if @api_client.present?

            @api_client = User.where(email: token[:client_id]).first
          end
<<<<<<< HEAD
          # rubocop:enable
=======
          # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
>>>>>>> upstream/master

          def decoded_auth_token
            return @token if @token.present?

            @token = JsonWebToken.decode(token: http_auth_header)
            @token
          rescue JWT::ExpiredSignature
<<<<<<< HEAD
            errors[:token] = _("Token expired")
=======
            errors[:token] = _('Token expired')
>>>>>>> upstream/master
            nil
          end

          # Extract the token from the Authorization header
          def http_auth_header
            hdr = @headers[:Authorization]
<<<<<<< HEAD
            errors[:token] = _("Missing token") unless hdr.present?
=======
            errors[:token] = _('Missing token') unless hdr.present?
>>>>>>> upstream/master
            return nil unless hdr.present?

            hdr.split.last
          end
<<<<<<< HEAD

        end

      end

    end

  end

=======
        end
      end
    end
  end
>>>>>>> upstream/master
end
