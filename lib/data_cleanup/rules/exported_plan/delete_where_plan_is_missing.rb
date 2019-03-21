# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete where plan is missing on ExportedPlan
    module ExportedPlan
      class DeleteWherePlanIsMissing < Rules::Base

        def description
          "ExportedPlan : Delete the exported plan when the plan doesn't exist anymore"
        end

        def call
          ::ExportedPlan.all.each do |exported|
            if exported.plan.nil?
              exported.delete()
            end
          end
        end
      end
    end
  end
end
