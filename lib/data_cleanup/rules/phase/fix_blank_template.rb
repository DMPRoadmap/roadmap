# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank template on Phase
    module Phase
      class FixBlankTemplate < Rules::Base

        def description
          "Fix blank template on Phase"
        end

        def call
          ids = ::Phase.joins("LEFT OUTER JOIN templates ON templates.id = phases.template_id")
                      .where(templates: { id: nil }).ids
          log("Destroying Phase without Template: #{ids}")
          ::Phase.destroy(ids)
        end
      end
    end
  end
end
