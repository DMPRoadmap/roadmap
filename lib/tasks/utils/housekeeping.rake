# frozen_string_literal: true

require "text"

# rubocop:disable Metrics/BlockLength
namespace :housekeeping do

  desc "Remove any expired OAuth access tokens for external APIs"
  task cleanup_external_api_access_tokens: :environment do
    # Removing expired and revoked Access Tokens
    ExternalApiAccessToken.where.not(revoked_at: nil).destroy_all
    ExternalApiAccessToken.where("expires_at <= ? ", Time.now).destroy_all
  end

end