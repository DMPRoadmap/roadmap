# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing feedback requested on Plan
    module Plan
      class FixMissingFeedbackRequested < Rules::Base

        def description
          "Plan: Set false for Plans with missing feedback requested"
        end

        def call
          ::Plan.where(feedback_requested: nil).update_all({feedback_requested: false})
        end
      end
    end
  end
end
