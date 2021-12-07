# frozen_string_literal: true

module Api

  # Derived from the Doorkeeper gem repository:
  #  https://github.com/doorkeeper-gem/doorkeeper/blob/main/spec/support/helpers/access_token_request_helper.rb
  module AccessTokenRequestHelper

    def client_is_authorized(client, resource_owner, access_token_attributes = {})
      token = build_token(client, resource_owner, access_token_attributes)
      # token.expects(:acceptable?).returns(true)
      token
    end

    def client_is_unauthorized(client, resource_owner, access_token_attributes = {})
      token = build_token(client, resource_owner, access_token_attributes)
      # token.allows(:acceptable?).and_returns(false)
      token
    end

    def build_token(client, resource_owner, access_token_attributes)
      attributes = {
        application: client,
        resource_owner_id: resource_owner.id
      }.merge(access_token_attributes)
      create(:oauth_access_token, attributes)
    end
  end

end

RSpec.configuration.send :include, Api::AccessTokenRequestHelper
