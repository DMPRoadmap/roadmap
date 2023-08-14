# frozen_string_literal: true

require 'text'
require 'httparty'

namespace :housekeeping do
  desc 'Clear the cache'
  task clear_cache: :environment do
    Rails.cache.clear
  end

  desc 'Monthly maintenance script'
  task monthly_maintenance: :environment do
    p '----------------------------------'
    p 'Step 1 of 7 - Purging old OAuth tokens and grants'
    Rake::Task['housekeeping:cleanup_oauth'].execute
    p '----------------------------------'
    p 'Step 2 of 7 - Purging old External API tokens'
    Rake::Task['housekeeping:cleanup_external_api_access_tokens'].execute
    p '----------------------------------'
    p 'Step 3 of 7 - Generating monthly usage statistics'
    Rake::Task['stat:build_last_month_parallel'].execute
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
      pauser = 0
      client_id = ApiClient.find_by(name: 'dmphub').id

      Plan.includes(:org, :research_outputs, :related_identifiers, :subscriptions, roles: [:user],
                    contributors: [:org, { identifiers: [:identifier_scheme] }])
          .where.not(dmp_id: nil)
          # .limit(600)
          .order(created_at: :desc)
          .each do |plan|
        next unless plan.dmp_id.present? && plan.complete? && !plan.is_test?
        next if DmpIdService.fetch_dmp_id(dmp_id: plan.dmp_id).nil?

        subscription = Subscription.where(plan: plan, subscriber_id: client_id, subscriber_type: 'ApiClient')
        next unless subscription.present?

        # Pause after every 10 so that we do not get rate limited
        sleep(3) if pauser >= 10
        pauser = pauser >= 10 ? 0 : pauser + 1

        if plan.owner.present?
          puts "Processing Plan: #{plan.id}, DMP ID: #{plan.dmp_id}"
          # Publish the updated meatdata to the DMP ID record
          if !DmpIdService.update_dmp_id(plan: plan).nil?
            puts "    Updated"
          else
            puts "    *** FAILED to update the DMP ID."
          end
        else
          puts "SKIPPING Plan: #{plan.id} because it is not 'Complete'."
        end
      end
    end
  end

  desc 'Remove any expired OAuth tokens and grants'
  task cleanup_oauth: :environment do
    # Removing expired Access Tokens and Grants to help prune the DB
    #   - Note that expiration values are stored in seconds!

    Doorkeeper::AccessGrant.all.each do |grant|
      expiry = grant.created_at + grant.expires_in.seconds
      grant.destroy if Time.zone.now >= expiry
    end

    Doorkeeper::AccessToken.all.each do |token|
      expiry = token.created_at + token.expires_in.seconds
      token.destroy if Time.zone.now >= expiry
    end
  end

  desc 'Remove any expired OAuth access tokens for external APIs'
  task cleanup_external_api_access_tokens: :environment do
    # Removing expired and revoked Access Tokens
    ExternalApiAccessToken.where.not(revoked_at: nil).destroy_all
    ExternalApiAccessToken.where('expires_at <= ? ', Time.zone.now).destroy_all
  end

  desc 'Remove old sessions'
  task cleanup_sessions: :environment do
    Session.where('updated_at <= ?', 3.months.from_now).destroy_all
  end
end
