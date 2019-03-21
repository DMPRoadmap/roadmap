# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing feedback email msg on Org
    module Org
      class FixMissingFeedbackEmailMsg < Rules::Base

        def description
          "Org: Set feedback email msg as 'Your feedback email here' for Org with missing feedback email msg"
        end

        def call
          ::Org.where(feedback_email_msg: ["", nil]).update_all({feedback_email_msg: "Your feedback email here"})
        end
      end
    end
  end
end
