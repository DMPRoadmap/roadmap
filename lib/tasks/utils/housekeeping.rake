# frozen_string_literal: true

require 'text'

namespace :housekeeping do
  desc 'Monthly maintenance script'
  task monthly_maintenance: :environment do
    p 'Step 1 of 7 - Purging old sessions'
    Rake::Task['housekeeping:cleanup_sessions'].execute
    p '----------------------------------'
    p 'Step 2 of 7 - Purging old OAuth tokens and grants'
    Rake::Task['housekeeping:cleanup_oauth'].execute
    p '----------------------------------'
    p 'Step 3 of 7 - Purging old External API tokens'
    Rake::Task['housekeeping:cleanup_external_api_access_tokens'].execute
    p '----------------------------------'
    p 'Step 4 of 7 - Fetching latest data from RDA Metadata standard catalog'
    Rake::Task['external_api:load_rdamsc_standards'].execute
    p '----------------------------------'
    p 'Step 5 of 7 - Fetching latest data from SPX license database'
    Rake::Task['external_api:load_spdx_licenses'].execute
    p '----------------------------------'
    p 'Step 6 of 7 - Fetching latest data from the re3data repository'
    Rake::Task['external_api:load_re3data_repos'].execute
    p '----------------------------------'
    p 'Step 7 of 7 - Fetching latest data from the ROR API'
    Rake::Task['external_api:sync_registry_orgs'].execute
  end

  desc 'Sync DMP metadata with the DMP ID minting authority'
  task sync_dmp_ids: :environment do
    scheme = IdentifierScheme.find_by(name: DmpIdService.identifier_scheme&.name)
    if scheme.present?
      Identifier.includes(:identifiable)
                .where(identifier_scheme_id: scheme.id, identifiable_type: 'Plan')
                .each do |identifier|
        DmpIdService.update_dmp_id(plan: identifier.identifiable)
      end
    else
      p 'No DMP ID minting authority defined so nothing to sync.'
    end
  end

  desc 'Remove any expired OAuth tokens and grants'
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

  desc 'Remove any expired OAuth access tokens for external APIs'
  task cleanup_external_api_access_tokens: :environment do
    # Removing expired and revoked Access Tokens
    ExternalApiAccessToken.where.not(revoked_at: nil).destroy_all
    ExternalApiAccessToken.where('expires_at <= ? ', Time.now).destroy_all
  end

  desc 'Remove old sessions'
  task cleanup_sessions: :environment do
    Session.where('updated_at <= ?', Time.now + 3.months).destroy_all
  end
end
