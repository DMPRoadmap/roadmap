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

      managed_orgs = Org.where(managed: true).pluck(:id)

      Identifier.includes(:identifiable)
                .where(identifier_scheme_id: scheme.id, identifiable_type: 'Plan')
                .where('identifiers.value LIKE ?', 'https://doi.org/%')
                # .where('plans.id IN ?', [87731, 86152, 83986, 82377, 81058, 75125, 66756])   # invalid data_access
                # .where('plans.id IN ?', [87612, 87617, 85046, 84553, 79981, 44403, 71338, 69614]) # no contact_id
                # .where('plans.id IN ?', [83085])                      # preregistration
                # .where('plans.id IN ?', [78147])                      # bad grant_id type
                # 77012, 70251, 69178, 67898, 66250 no contact
                # .where('identifiable_id = ? AND identifiable_type = ?', 59943, 'Plan')
                .distinct
                .limit(100)
                .order(created_at: :desc)
                .each do |identifier|
        next unless identifier.value.present? && identifier.identifiable.present?

        # Pause after every 10 so that we do not get rate limited
        sleep(3) if pauser >= 10
        pauser = pauser >= 10 ? 0 : pauser + 1

        # Refetch the Plan and all of it's child objects
        plan = Plan.includes(:org, :research_outputs, :related_identifiers, roles: [:user],
                              contributors: [:org, { identifiers: [:identifier_scheme] }],
                              identifiers: [:identifier_scheme])
                    .find_by(id: identifier.identifiable.id)


        next unless managed_orgs.include?(plan.org_id) && !plan.is_test?

        puts "Processing Plan: #{identifier.identifiable_id}, DMP ID: #{identifier.value}"
        identifier = DmpIdService.mint_dmp_id(plan: plan, seeding: true)

        if identifier.is_a?(Identifier)
          puts "    registered #{identifier.value}"
          identifier.save
          puts "    uploading narrative PDF"
          PdfPublisherJob.perform_now(plan: plan) if identifier.is_a?(Identifier)
        end
=begin
        begin
          # See if it exists
          puts "Processing Plan: #{identifier.identifiable_id}, DMP ID: #{identifier.value}"
          url = "#{DmpIdService.landing_page_url}#{identifier.value}"
          url = identifier.value.to_s.gsub('https://doi.org', "#{DmpIdService.api_base_url}dmps")
          puts "    - #{url}"
          resp = HTTParty.get(url, { follow_redirects: true, limit: 6 })

          case resp.code
          when 404, 500
            puts "   Registering new DMP ID"
            identifier = DmpIdService.mint_dmp_id(plan: plan, seeding: true)
            identifier.save if identifier.is_a?(Identifier)
          when 200
            puts "   Already registered at #{url}"
            # puts "   Updating DMP ID"
            # DmpIdService.update_dmp_id(plan: plan)
          else
            puts "   Unable to process DMP - got a #{resp.code} from #{DmpIdService.name}"
            puts resp.body
          end
        rescue StandardError => e
          puts "    ERROR: DMP ID: #{identifier.value} - #{e.message}"
        end
=end
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
