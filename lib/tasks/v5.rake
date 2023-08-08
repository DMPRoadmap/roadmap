# frozen_string_literal: true

# Upgrade tasks for 5.x versions. See https://github.com/DMPRoadmap/roadmap/releases for information
# on how and when to run each task.

# rubocop:disable Naming/VariableNumber
namespace :v5 do
  # TODO: In the next release drop column repositories.custom_repository_owner_template_id
  # TODO: In the next release drop columns output_type & output_type_description from research_outputs

  desc 'Upgrade from v4.x to v5.0'
  task upgrade_5_0: :environment do
    puts 'Adding Funder API information for new React UI project/award search'
    host = Rails.env.development? ? 'http://localhost:3000' : ENV['DMPROADMAP_HOST']

    # Funders that have Crossref Grant Ids
    crossref_funder_ids = ['100004440', '100000015', '501100002241', '100001545', '100001771', '100000048', '100000980',
                           '501100001821', '100000968', '100008984', '100000893', '100000971', '100005202', '100000936',
                           '100000913', '100005190', '100005536', '501100000223', '100006309', '100010586', '100008539',
                           '501100011730', '100010581']
    RegistryOrg.where(fundref_id: crossref_funder_ids).where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/crossref/10.13039/#{ror_org.fundref_id}",
        api_guidance: 'Please enter an award DOI (e.g. 10.12345/abcd.proj.2008/abc123) or a combination of title keywords, PI names and the award year.',
        api_query_fields: '[{"label": "Award DOI", "query_string_key": "project"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    # Funders that use the NIH Awards API
    RegistryOrg.where('LOWER(name) LIKE ?', '%nih.gov%').where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/nih",
        api_guidance: 'Please enter a project/application id (e.g. 5R01AI00000, 1234567) or a combination of title keywords, PI names, FOA opportunity id (e.g. PA-11-111) and the award year.',
        api_query_fields: '[{"label": "Project/Application id", "query_string_key": "project"}, {"label": "FOA opportunity id", "query_string_key": "opportunity"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    RegistryOrg.where('LOWER(name) LIKE ? OR LOWER(name) LIKE ?', '%nasa.gov%', '%nsf.gov%').where(api_target: nil).each do |ror_org|
      ror_org.update(
        api_target: "#{host}/api/v3/awards/nsf",
        api_guidance: 'Please enter an award id (e.g. 1234567) or a combination of title keywords, PI names and the award year.',
        api_query_fields: '[{"label": "Award id", "query_string_key": "project"}, {"label": "PI names", "query_string_key": "pi_names"}, {"label": "Title keywords", "query_string_key": "title"}, {"label": "Award year", "query_string_key": "years"}]'
      )
    end

    puts 'The following RegistryOrg records now have award/grant API information for the React UI.'
    RegistryOrg.where.not(api_target: nil).each do |ror_org|
      puts "      ID: #{ror_org.id}   |   NAME: #{ror_org.name}   |   API_TARGET: #{ror_org.api_target}"
    end
  end

  desc 'Move existing identifiers.value to plans.dmp_id'
  task move_dmp_ids: :environment do
    scheme = IdentifierScheme.find_by(name: DmpIdService.identifier_scheme&.name)
    if scheme.present?
      pauser = 0

      managed_orgs = Org.where(managed: true).pluck(:id)

      # Modify this query if you want to test a subset of DMP IDs first
      identifiers = Identifier.includes(:identifiable)
                              .where(identifier_scheme_id: scheme.id, identifiable_type: 'Plan')
                              .where('identifiers.value LIKE ?', 'https://doi.org/%')
                              # .where('identifiable_id IN ?', [87731, 86152, 83986, 82377, 81058, 75125, 66756])   # invalid data_access
                              # .where('identifiable_id IN ?', [87612, 87617, 85046, 84553, 79981, 44403, 71338, 69614]) # no contact_id
                              # .where('identifiable_id IN ?', [83085])                      # preregistration
                              # .where('identifiable_id IN ?', [78147])                      # bad grant_id type
                              # 77012, 70251, 69178, 67898, 66250 no contact
                              # .where('identifiable_id = ? AND identifiable_type = ?', 59943, 'Plan')
                              # .where('identifiable_id IN (?)', %i[71800 71809]) # test with Hakai DMPs
                              .distinct
                              # .limit(200)
                              .order(created_at: :desc)

      identifiers.each do |identifier|
        next unless identifier.value.present? && identifier.identifiable.present?

        # Refetch the Plan and all of it's child objects
        plan = Plan.find_by(id: identifier.identifiable.id).where(dmp_id: nil)
        plan.dmp_id = identifier.value
        if plan.save
          identifier.destroy
          puts "  moved #{plan.dmp_id} for Plan #{plan.id}"
        else
          puts "  FAIL #{plan.errors.full_messages}"
        end
      end
    end
  end

  # This should only ever be run if you have been using the Rails based DMPHub system (https://github.com/CDLUC3/dmphub)
  # to register DMP IDs and would like to transition those identifiers to the new DMPHub system base in the AWS
  # API Gateway, Lambdas, S3 and DynamoDB (https://github.com/CDLUC3/dmp-hub-cfn).
  #
  # Note that you may need to update the DOI records from your minting authority (e.g. DataCite, Crossref, etc.)
  # if the URL to the new DMPHub will use a different domain name!
  #
  # If you want to retain the existing DMP IDs, you will need to make sure that your 'dmptool' Provenance record in
  # the new DMPHub system's DynamoDB table has `"seedingWithLiveDmpIds": true,`!
  #
  # A successful run will add the DMP ID metadata to the DynamoDB and eithger use the existing DMP ID (if you have
  # set the `seedingWithLiveDmpIds` correctly) or will mint a new ID. It will also render the current narative PDF
  # document for the record, upload it to the DMPHub's S3 bucket, and add an `is_metadata_for` related_identifier
  # that includes the download URL for the narrative PDF. It will add the DMP ID (new or reused) to the `plans.dmp_id`
  # field and remove the associated Identifier that holds the current DMP ID reference
  #
  desc 'Transfer existing DMP IDs from the old DMPHub Rails based system to the new one in AWS API Gateway'
  task seed_dmphub: :environment do
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

        recent_subscriptions = Subscription.where(plan: plan, subscriber_id: client_id, subscriber_type: 'ApiClient')
                                           .where('last_notified > ?', (Time.now - 1.day).strftime('%Y-%m-%d %H:%M:%S'))
        next if recent_subscriptions.any?
        next unless DmpIdService.fetch_dmp_id(dmp_id: plan.dmp_id).nil?

        # Pause after every 10 so that we do not get rate limited
        sleep(3) if pauser >= 20
        pauser = pauser >= 20 ? 0 : pauser + 1

        if plan.owner.present?
          puts "Processing Plan: #{plan.id}, DMP ID: #{plan.dmp_id}"
          # Call the DMPHub to register the DMP ID and upload the narrative PDF (performed async by ActiveJob)
          hash = DmpIdService.mint_dmp_id(plan: plan, seeding: true)
          if hash.is_a?(Hash) && hash[:dmp_id].present?
              # Add the DMP ID to the Dmp record
            if plan.update(dmp_id: hash[:dmp_id])
              # Remove the old subscription for the item. The minting process added a new entry so we don't want the old
              old_subscriptions = Subscription.where(plan: plan, subscriber_id: client_id, subscriber_type: 'ApiClient')
                                              .where('last_notified < ?', (Time.now - 1.day).strftime('%Y-%m-%d %H:%M:%S'))
              old_subscriptions.destroy_all

              puts "    registered #{plan.dmp_id}. Uploading narrative ..."
              if PdfPublisherJob.perform_now(plan: plan)
                plan = plan.reload
                puts "        uploaded to #{plan.narrative_url}"
              else
                puts "        *** FAILED to upload narrative!"
              end
            else
              puts "    *** FAILED to save DMP ID to plan record!"
            end
          else
            puts "    *** FAILED to register DMP ID."
          end
        else
          puts "SKIPPING Plan: #{plan.id} because it is not 'Complete'."
        end
      end
    else
      p 'No DMP ID minting authority defined so nothing to sync.'
    end
  end
end
# rubocop:enable Naming/VariableNumber
