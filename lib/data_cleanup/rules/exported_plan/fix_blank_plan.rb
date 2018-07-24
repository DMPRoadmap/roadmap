# frozen_string_literal: true

module DataCleanup
  module Rules
    # Fix blank plan on ExportedPlan
    module ExportedPlan
      class FixBlankPlan < Rules::Base

        def description
          "Fix blank plan on ExportedPlan"
        end

        def call
          ::ExportedPlan.where(plan: nil).delete_all
        end
      end
    end
  end
end
