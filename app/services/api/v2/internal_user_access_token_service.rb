# frozen_string_literal: true

module Api
  module V2
    # Service responsible for user-scoped v2 API access tokens, strictly for
    # internal users of this application.
    #
    # Tokens issued by this service are functionally equivalent to Personal Access
    # Tokens (PATs) for first-party usage. They are minted directly for a user
    # who is already authenticated in the application, bypassing the standard
    # OAuth 2.0 authorization_code redirect and consent flow.
    #
    # This design is intentional:
    # - tokens are internal to this application (first-party)
    # - tokens are owned by a single user and scoped accordingly
    # - token creation, rotation, and revocation happen entirely within the app UI
    #
    # Tokens are stored as Doorkeeper::AccessToken records to leverage existing
    # scoping, expiry, and revocation mechanisms.
    #
    # This service does NOT support third-party OAuth clients or delegated consent flows.
    class InternalUserAccessTokenService
      READ_SCOPE = 'read'
      APPLICATION = Doorkeeper::Application.find_by(
        name: Rails.application.config.x.application.internal_oauth_app_name
      )

      class << self
        def for_user(user)
          Doorkeeper::AccessToken.find_by(
            application_id: application!.id,
            resource_owner_id: user.id,
            scopes: READ_SCOPE,
            revoked_at: nil
          )
        end

        def rotate!(user)
          revoke_existing!(user)

          Doorkeeper::AccessToken.create!(
            application_id: application!.id,
            resource_owner_id: user.id,
            scopes: READ_SCOPE,
            expires_in: nil # Overrides Doorkeeper's `access_token_expires_in`
          )
        end

        private

        def revoke_existing!(user)
          Doorkeeper::AccessToken.revoke_all_for(application!.id, user)
        end
      end
    end
  end
end
