# Upgrade tasks for 3.x versions. See https://github.com/DMPRoadmap/roadmap/releases for information
# on how and when to run each task.

namespace :v3 do

  desc "Upgrade from v3.0.3 to v3.0.4"
  task upgrade_3_0_4: :environment do
    Rake::Task["v3:define_default_guidance_group"].execute
  end

  desc "Upgrade from v2.2.0 to v3.0.0"
  task upgrade_3_0_0: :environment do
    Rake::Task["v3:ensure_default_languages"].execute
    Rake::Task["v3:ensure_feedback_defaults"].execute
    Rake::Task["v3:fix_funder_ids"].execute
  end

  desc "Upgrade from v3.0.0 to v3.1.0"
  task upgrade_3_1_0: :environment do
    Rake::Task["mime_types:load"].execute
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

    if Org.respond_to?(:feedback_email_subject)
      Org.where(feedback_email_subject: nil).update_all(feedback_email_subject: feedback_confirmation_default_subject)
      Org.where(feedback_email_msg: nil).update_all(feedback_email_msg: feedback_confirmation_default_message)
    else
      Org.where(feedback_msg: nil).update_all(feedback_msg: feedback_confirmation_default_message)
    end
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

  desc "Sets the default guidance group"
  task define_default_guidance_group: :environment do
    # The default guidance group used to be derived from the
    # config/initializers/_dmproradmap.rb config file by connecting the
    # `organisation.abbreviation` to a record in the Org table.
    #
    # This proves to be somewhat fragile and requires us to ensure that the
    # config always matches the correct Org record.
    #
    # This script will set the new `guidance_groups.is_default` flag for the
    # correct Org.
    config_val = Rails.configuration.x.organisation.abbreviation
    dflt_tmplt = Template.where(is_default: true).first



    org = Org.where("LOWER(abbreviation) = ?", config_val.downcase).first
    gg = GuidanceGroup.where(org_id: org.id, published: true).first if org.present?

    org = Org.where(id: dflt_tmplt.org_id).first unless gg.present?

    if gg.present?
      p "Detected default Org '#{org.name}'. Setting their GuidanceGroup \
         as the default."
      gg.update(is_default: true)
    else
      if org.present?
        p "FATAL: Unable to set the default GuidanceGroup for '#{org.name}' \
                  because they have no published GuidanceGroup!"
      else
        p "FATAL: Unable to determine the default GuidanceGroup because no Org \
                  matched the `organisation.abbreviation` defined in the \
                  '_dmproadmap.rb' initializer and no Default template was defined!"
      end
    end
  end

end
