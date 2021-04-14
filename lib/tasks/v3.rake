namespace :v3 do

  desc "Upgrade from v2.2.0 to v3.0.0"
  task upgrade_3_0_0: :environment do
    Rake::Task["v3:ensure_default_languages"].execute
    Rake::Task["v3:ensure_feedback_defaults"].execute
    Rake::Task["v3:fix_funder_ids"].execute
  end

  desc "Upgrade from v3.0.0 to v3.1.0"
  task upgrade_3_1_0: :environment do
    Rake::Task["v3:mime_types:load"].execute
    Rake::Task["v3:init_open_aire"].execute
    Rake::Task["v3:datacite"].execute
    Rake::Task["v3:init_re3data"].execute
    Rake::Task["v3:seed_external_services"].execute
    Rake::Task["v3:load_re3data_repos"].execute
    Rake::Task["v3:load_spdx_licenses"].execute
    Rake::Task["v3:backfill_doi_subscriptions"].execute
  end

  # Set any records with a nil `language_id` to the default language
  desc "Change nil language_id entries into the default language"
  task ensure_default_languages: :environment do
    dflt = Language.default

    unless dflt.present?
      if Language.all.any?
        # If there are languages but no default then use the first one and make it the default!
        dflt = Language.first
        dflt.update(default_language: true) unless dflt.default_language
      else
        # In the event that there are no Languages defined, define the default
        dflt = Language.create(abbreviation: 'en-GB', description: 'English (Great Britain)', default_language: true)
      end
    end

    Org.where(language: nil).update_all(language_id: dflt.id)
    User.where(language: nil).update_all(language_id: dflt.id)
  end

  # Set any records with a nil `feedback_email_[subject|message]` to the default
  desc "Change nil feedback_email_subject and feedback_email_message to the defaults"
  task ensure_feedback_defaults: :environment do
    include FeedbacksHelper

    Org.where(feedback_email_subject: nil).update_all(feedback_email_subject: feedback_confirmation_default_subject)
    Org.where(feedback_email_msg: nil).update_all(feedback_email_msg: feedback_confirmation_default_message)
  end

  # E.G. change 'https://api.crossref.org/funders/100000060' to 'https://doi.org/10.13039/100000060'
  desc "Corrects the Crossref funder ids which were originally set to the URL instead of the DOI"
  task fix_funder_ids: :environment do
    scheme = IdentifierScheme.where(name: "fundref").first

    incorrect_prefix = "https://api.crossref.org/funders/"
    correct_prefix = "https://doi.org/10.13039/"

    if scheme.present?
      scheme.update(identifier_prefix: correct_prefix) unless scheme.identifier_prefix == correct_prefix
      Identifier.where(identifier_scheme: scheme).each do |id|
        next unless id.value.start_with?(incorrect_prefix)

        id.update(value: id.value.gsub(incorrect_prefix, correct_prefix))
        p "#{id.value} - #{id.valid?}"
        p id.errors.full_messages
      end
    end
  end

  desc "Seed the identifier_schemes.external_service column"
  task seed_external_services: :environment do
    ror = IdentifierScheme.where(name: "ror")
    ror.update(external_service: "ExternalApis::RorService") if ror.present?

    openaire = IdentifierScheme.where(name: "openaire")
    openaire.update(external_service: "ExternalApis::OpenAireService") if openaire.present?

    re3data = IdentifierScheme.where(name: "rethreedata")
    re3data.update(external_service: "ExternalApis::Re3dataService") if re3data.present?
  end

  desc "Adds the open_aire IdentifierScheme for ResearchOutputs"
  task init_open_aire: :environment do
    openaire = IdentifierScheme.find_or_initialize_by(name: "openaire")
    openaire.for_research_outputs = true
    openaire.description = "OpenAire Metadata Standards"
    openaire.identifier_prefix = ""
    openaire.external_service = "ExternalApis::OpenAireService"
    openaire.active = true
    openaire.save
  end

  desc "Adds the re3data IdentifierScheme for ResearchOutputs"
  task init_re3data: :environment do
    re3data = IdentifierScheme.find_or_initialize_by(name: "rethreedata")
    re3data.for_research_outputs = true
    re3data.description = "Registry of Research Data Repositories (re3data)"
    re3data.identifier_prefix = "https://www.re3data.org/api/v1/repository/"
    re3data.external_service = "ExternalApis::Re3dataService"
    re3data.active = true
    re3data.save
  end

  desc "Adds the DataCite IdentifierScheme for minting DMP IDs (DOIs)"
  task init_datacite: :environment do
    datacite = IdentifierScheme.find_or_initialize_by(name: "datacite")
    datacite.for_plans = true
    datacite.for_identification = true
    datacite.description = "DataCite"
    datacite.identifier_prefix = "https://doi.org/"
    datacite.external_service = "ExternalApis::DataciteService"
    datacite.active = false
    datacite.save
  end

  desc "Adds the DMPHub for minting DMP IDs (DOIs)"
  task init_dmphub: :environment do
    datacite = IdentifierScheme.find_or_initialize_by(name: "dmphub")
    datacite.for_plans = true
    datacite.for_identification = true
    datacite.description = "DMPHub"
    datacite.identifier_prefix = "https://doi.org/"
    datacite.external_service = "ExternalApis::DmphubService"
    datacite.active = false
    datacite.save
  end

  desc "Load Repositories from re3data"
  task load_re3data_repos: :environment do
    Rails::Task["v3:init_re3data"].execute unless IdentifierScheme.find_by(name: "rethreedata").present?
    ExternalApis::Re3dataService.fetch
  end

  desc "Load Licenses from SPDX"
  task load_spdx_licenses: :environment do
    ExternalApis::SpdxService.fetch
  end

  desc "Add the DOI Service as an api_client (if necessary) and then set it as subscriber to DOIs"
  task backfill_doi_subscriptions: :environment do
    p "Backfilling subscriptions on existing DOIs"
    if DoiService.minting_service_defined?
      # First initialize or find the ApiClient for the DOI Service
      scheme_name = DoiService.scheme_name
      api_client = ApiClient.find_or_initialize_by(name: scheme_name)
      api_client.contact_name = "#{ApplicationService.application_name} helpdesk" if api_client.new_record?
      api_client.contact_email = Rails.configuration.x.organisation.helpdesk_email if api_client.new_record?
      api_client.save if api_client.new_record?

      scheme = IdentifierScheme.find_by(name: scheme_name)
      if scheme.present? && api_client.present?
        Identifier.where(identifier_scheme_id: scheme.id, identifiable_type: "Plan").each do |id|
          next if Subscription.where(subscriber: api_client, plan_id: id.identifiable_id).any?

          Subscription.create(
            subscriber: api_client,
            plan_id: id.identifiable_id,
            updates: true,
            deletions: true,
            callback_uri: DoiService.scheme_callback_uri % { dmp_id: id.value.gsub(scheme.identifier_prefix, "") },
          )
        end
      else
        p "No IdentifierScheme by the name of '#{scheme_name}' found!"
      end
    else
      p "DOI Minting service is not defined. Skipping backfill of DOI subscriptions"
    end
  end

end
