# frozen_string_literal: true

require "text"

# rubocop:disable Metrics/BlockLength
namespace :housekeeping do

  desc "Remove any expired OAuth tokens and grants"
  task cleanup_oauth: :environment do
    # Removing expired Access Tokens and Grants to help prune the DB
    #   - Note that expiration values are stored in seconds!

    Doorkeeper::AccessGrant.all.each do |grant|
      expiry = grant.created_at + grant.expires_in.seconds
      grant.destroy if Time.now >= expiry
    end

    Doorkeeper::AccessToken.all.each do |token|
      expiry = token.created_at + token.expires_in.seconds
      token.destroy if Time.now >= expiry
    end
  end

  desc "Remove any expired OAuth access tokens for external APIs"
  task cleanup_external_api_access_tokens: :environment do
    # Removing expired and revoked Access Tokens
    ExternalApiAccessToken.where.not(revoked_at: nil).destroy_all
    ExternalApiAccessToken.where("expires_at <= ? ", Time.now).destroy_all
  end

end
