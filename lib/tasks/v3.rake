namespace :v3 do

  desc "Upgrade from v2.2.0 to v3.0.0"
  task upgrade_3_0_0: :environment do
    Rake::Task["v3:ensure_default_languages"].execute
    Rake::Task["v3:ensure_feedback_defaults"].execute
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

end
