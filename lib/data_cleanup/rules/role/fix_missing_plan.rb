# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing plan on Role
    module Role
      class FixMissingPlan < Rules::Base

        def description
          "Role: Delete roles without associated plans"
        end

        def call
          ::Role.where(plan_id: nil).delete_all()
        end
      end
    end
  end
end
