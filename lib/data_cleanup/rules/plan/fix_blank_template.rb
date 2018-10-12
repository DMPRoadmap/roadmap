# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank template on Plan
    module Plan
      class FixBlankTemplate < Rules::Base

        def description
          "Fix blank template on Plan"
        end

        def call
          ids = ::Plan.joins("LEFT OUTER JOIN templates ON templates.id = plans.template_id")
                      .where(templates: { id: nil }).ids
          log("Destroying Plan without Template: #{ids}")
          ::Plan.destroy(ids)
        end
      end
    end
  end
end
