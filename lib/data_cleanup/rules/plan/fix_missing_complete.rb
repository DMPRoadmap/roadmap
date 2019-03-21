# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing complete on Plan
    module Plan
      class FixMissingComplete < Rules::Base

        def description
          "Plan: Set false for Plans with missing complete"
        end

        def call
          ::Plan.where(complete: nil).update_all({complete: false})
        end
      end
    end
  end
end
