# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank plan on Role
    module Role
      class FixBlankPlan < Rules::Base

        def description
          "Fix blank plan on Role"
        end

        def call
          ::Role.where(plan: nil).destroy_all
        end
      end
    end
  end
end
