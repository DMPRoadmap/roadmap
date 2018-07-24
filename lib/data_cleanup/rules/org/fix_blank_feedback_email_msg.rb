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
          "Fix orgs where feedback_enabled is true"
        end

        def call
          ::Org.where(feedback_enabled: true, feedback_email_msg: "")
             .update_all(feedback_email_msg: DEFAULT_MSG)
        end
      end
    end
  end
end
