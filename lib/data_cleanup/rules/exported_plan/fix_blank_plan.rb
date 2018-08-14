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
          # Find all exported plans where the corresponding plan doesn't exist.
          ::ExportedPlan
            .joins("LEFT OUTER JOIN plans on plans.id = exported_plans.plan_id")
            .where(plans: { id: nil }).each do |exported_plan|
            log("Destroying ExportedPlan##{exported_plan.id} where plan is nil")
            exported_plan.destroy
          end
        end
      end
    end
  end
end
