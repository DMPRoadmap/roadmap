# frozen_string_literal: true

# == Schema Information
#
# Table name: oauth_credentials_tokens
#
#  id                :integer          not null, primary key
#  resource_owner_id :integer          not null
#  application_id    :integer          not null
#  token             :string           not null
#  created_at        :datetime         not null
#  revoked_at        :datetime
#  last_access_at    :datetime
#  scopes            :string           not null, default: 'public'
#
# Indexes
#
#  index_oauth_credential_tokens_on_resource_owner_id (resource_owner_id)
#  index_oauth_credential_tokens_on_application_id    (application_id)
#  index_oauth_credential_tokens_on_token             (token)
#
# Foreign Keys
#
#  fk_rails_...  (resource_owner_id => users.id)
#  fk_rails_...  (application_id => oauth_applications.id)
#
class OauthCredentialToken < ApplicationRecord
  # This class is used as part of the API V2+ OAuth workflow. They store a unique token that
  # an external ApiClient can use (along with a user's :uid) to access resources on the User's
  # behalf.
  #
  # In a normal OAuth2 workflow, a user must be signed in at all times in order for the ApiClient
  # to access their data. That approach works well for site's like Google or Twitter where a user
  # is often logged in. It does not work well though for a DMPRoadmap system since our users are
  # typically logged in only when writing their plans and not when their research projects are
  # in later stages.
  #
  # When an ApiClient attempts to access a User's data (e.g. Plans, profile info, etc.) the User
  # is asked to sign in (skipped if they are already signed in on another tab/window) and authorize
  # the external system to access their information. Once they have authorized the integration, their :uid
  # and an OauthCredentialToken.token are sent to the ApiClient. It is up to the ApiClient to store these
  # values on their side. The ApiClient can then use those values to access the User's data (which still
  # follows the OAuth2 workflow of passing the credentials to receive an AccessToken used in calls to the API).
  #
  # These OauthCredentialTokens are managed by the `config/initializers/doorkeeper.rb` initializer. They
  # are created in the `after_successful_authorization` hook and checked/verified in the
  # `resource_owner_from_credentials` method that gets executed during a `grant_type = password` Oauth
  # grant flow.
  #
  # OauthCredentialTokens are long lived and do not expire by default. User's can however revoke these
  # tokens on the API tab of their profile page.
  #
  # Note that these tokens tie into the `scopes` concept of the OAuth2 workflow. When the user authorizes
  # the ApiClient to access their data, they are confirming certain scopes (e.g. read_dmps, edit_dmps, etc.)
  # a scope check is part of the
  # See the OAuth wiki for full details:
  #   https://github.com/DMPRoadmap/roadmap/wiki/API-Documentation-V2

  extend UniqueRandom

  # ================
  # = ASSOCIATIONS =
  # ================

  belongs_to :user, foreign_key: :resource_owner_id

  belongs_to :api_client, foreign_key: :application_id

  # =============
  # = CALLBACKS =
  # =============

  before_validation :generate_token, on: :create

  # =================
  # = CLASS METHODS =
  # =================

  class << self

    # Looking for not revoked tokens with a matching set of scopes that belongs to
    # specific Application and Resource Owner. If it doesn't exists - then create it.
    #
    # This method was derived from the Doorkeeper::AccessTokenMixin
    #    https://github.com/doorkeeper-gem/doorkeeper/blob/73a2b1ce04a7833a82e9b53d80fe737f279e2c44/lib/doorkeeper/models/access_token_mixin.rb#L182
    def find_or_create_for!(application:, resource_owner:, scopes:)
      credential_token = matching_token_for(application, resource_owner, scopes)
      return credential_token if credential_token.present?

      create(application_id: application&.id, resource_owner_id: resource_owner&.id, scopes: scopes)
    end

    # Find the matching record for the specified Application and token
    def find_for(client_id:, token:)
      find_by(application_id: ApiClient.find_by(uid: client_id)&.id, token: token, revoked_at: nil)
    end

  end

  # ====================
  # = INSTANCE METHODS =
  # ====================

  # Generates a unique token value
  def generate_token
    self.token = OauthCredentialToken.unique_random(field_name: "token")
  end

  private

  # =========================
  # = PRIVATE CLASS METHODS =
  # =========================

  class << self

    # Looking for not revoked Access Token with a matching set of scopes that belongs to specific
    # Application and Resource Owner.
    #
    # This method was derived from the Doorkeeper::AccessTokenMixin
    #    https://github.com/doorkeeper-gem/doorkeeper/blob/73a2b1ce04a7833a82e9b53d80fe737f279e2c44/lib/doorkeeper/models/access_token_mixin.rb#L89
    def matching_token_for(application, resource_owner, scopes)
      # Looking for not revoked Creential Tokens that belongs to specific Application and Resource Owner.
      where(api_client: application, user: resource_owner, revoked_at: nil)
        .select { |token| scopes_match?(token.scopes, scopes, application&.scopes) }.first
    end

    # Checks whether the token scopes match the scopes from the parameters
    #
    # This method was derived from the Doorkeeper::AccessTokenMixin
    #    https://github.com/doorkeeper-gem/doorkeeper/blob/73a2b1ce04a7833a82e9b53d80fe737f279e2c44/lib/doorkeeper/models/access_token_mixin.rb#L152
    def scopes_match?(token_scopes, param_scopes, app_scopes)
      return true if token_scopes.empty? && param_scopes.empty?

      token_scopes = token_scopes.split if token_scopes.is_a?(String)
      param_scopes = param_scopes.split if param_scopes.is_a?(String)

      (token_scopes.sort == param_scopes.sort) &&
        Doorkeeper::OAuth::Helpers::ScopeChecker.valid?(
          scope_str: param_scopes.to_s,
          server_scopes: Doorkeeper.config.scopes,
          app_scopes: app_scopes,
        )
    end

  end

end