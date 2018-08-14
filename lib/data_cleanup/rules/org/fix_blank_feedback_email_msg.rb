module DataCleanup
  module Rules
    module Org
      class FixBlankFeedbackEmailMsg < Rules::Base

        DEFAULT_MSG = <<~HTML
<p>Hello %{user_name}.</p>
<p>
  Your plan "%{plan_name}" has been submitted for feedback from an administrator
  at your organisation. If you have questions
  pertaining to this action, please contact us at %{organisation_email}.
</p>
        HTML

        def description
          "Fix orgs feedback_email_message is blank"
        end

        def call
          ids = ::Org.where(feedback_enabled: true, feedback_email_msg: "").pluck(:id)
          log("Adding default feedback_enabled for orgs: #{ids}")
          ::Org.where(feedback_enabled: true, feedback_email_msg: "")
             .update_all(feedback_email_msg: DEFAULT_MSG)
        end
      end
    end
  end
end
