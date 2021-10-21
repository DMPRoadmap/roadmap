# frozen_string_literal: true

module Api

  module V1

    module Auth

      module Jwt

        class JsonWebToken

          class << self

            def encode(payload:, exp: 24.hours.from_now)
              payload[:exp] = exp.to_i
              JWT.encode(payload, Rails.application.credentials.secret_key_base)
            rescue JWT::EncodeError => e
              Rails.logger.error "Api::V1::Auth::Jwt::JsonWebToken.encode - #{e.message}"
              nil
            end

            def decode(token:)
              body = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
              ActiveSupport::HashWithIndifferentAccess.new body
            rescue JWT::ExpiredSignature => e
              raise e
            rescue JWT::DecodeError => e
              Rails.logger.error "Api::V1::Auth::Jwt::JsonWebToken.decode - #{e.message}"
              nil
            end

          end

        end

      end

    end

  end

end
