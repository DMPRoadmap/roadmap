# frozen_string_literal: true

module Dmptool

  module User

    extend ActiveSupport::Concern

    class_methods do

      # ============
      # = Omniauth =
      # ============

      # Load the user based on the scheme and id provided by the Omniauth call
      def from_omniauth(scheme)
        omniauth_hash = omniauth_from_request
        return nil unless omniauth_hash[:uid].present?

        # Find the User by the :uid returned by omniauth
        user = Identifier.by_scheme_name(scheme, "User")
                        .where(value: omniauth_hash[:uid])
                        .first&.identifiable
        return user if user.present?

          omniauth_info = omniauth_hash.fetch(:info, {})
          names = extract_omniauth_names(hash: omniauth_info)

            user = User.new(
              email: extract_omniauth_email(hash: omniauth_info),
              firstname: names.fetch(:firstname, ""),
              surname: names.fetch(:surname, ""),
              org: extract_omniauth_org(scheme: scheme, hash: omniauth_info)
            )

            # Get the Oauth access token if available
            token = ExternalApiAccessToken.from_omniauth(user: user, service: scheme.name, hash: @omniauth)
            user.external_api_access_tokens = [token] if token.present?
            user
      end

      # Extract the omniauth info from the request
      def omniauth_from_request
        return {} unless request.env.present?

        hash = request.env["omniauth.auth"]
        hash = request.env[:"omniauth.auth"] unless hash.present?
        hash = hash.present? ? hash : request.env
        hash.hash_with_indifferent_access
      end

      # Extract the 1st email
      def extract_omniauth_email(hash:)
        hash.present? ? hash.fetch(:email, "").split(";")[0] : nil
      end

      # Find the User names from the omniauth info
      def extract_omniauth_names(hash:)
        return {} unless hash.present?

        out = {
          firstname: hash.fetch(:givenname, hash.fetch(:firstname, "")),
          surname: hash.fetch(:sn, hash.fetch(:surname, hash.fetch(:lastname, "")))
        }
        return out if out[:firstname].present? || out[:surname].present?

        names = hash[:name].split(" ")
        {
          firstname: names[0],
          surname: names.length > 1 ? names[names.length - 1] : nil
        }
      end

    end

    included do

      # ==================
      # = API V2 HELPERS =
      # ==================

      # Fetch the access token for the specified service
      def access_token_for(external_service_name:)
        return nil unless external_service_name.present? && external_api_access_tokens.any?

        tokens = external_api_access_tokens.select do |token|
          token.external_service_name == external_service_name && token.active?
        end
        tokens.first
      end

    end

  end

end
