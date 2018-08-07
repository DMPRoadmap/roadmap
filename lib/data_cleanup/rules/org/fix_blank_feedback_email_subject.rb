module DataCleanup
  module Rules
    module Org
      class FixBlankFeedbackEmailSubject < Rules::Base

        DEFAULT_SUBJECT = "%{application_name}: Your plan has been submitted for feedback"

        def description
          "Fix orgs where feedback_enabled is true"
        end

        def call
          ids = ::Org.where(feedback_enabled: true, feedback_email_subject: "").pluck(:id)
          log("Adding default feedback_email_subject for orgs: #{ids}")
          ::Org.where(feedback_enabled: true, feedback_email_subject: "")
               .update_all(feedback_email_subject: DEFAULT_SUBJECT)
        end
      end
    end
  end
end
