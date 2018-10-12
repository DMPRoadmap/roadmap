module DataCleanup
  module Rules
    module Org
      class FixBlankFeedbackEmailSubject < Rules::Base

        DEFAULT_SUBJECT = "%{application_name}: Your plan has been submitted for feedback"

        def description
          "Fix orgs where feedback_email_subject is blank"
        end

        def call
          ids = ::Org.where(feedback_enabled: true, feedback_email_subject: [nil, ""]).pluck(:id)
          log("Adding default feedback_email_subject for orgs: #{ids}")
          ::Org.where(id: ids)
               .update_all(feedback_email_subject: DEFAULT_SUBJECT)
        end
      end
    end
  end
end
