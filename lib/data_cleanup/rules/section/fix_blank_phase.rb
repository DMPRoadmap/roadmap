# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank phase on Section
    module Section
      class FixBlankPhase < Rules::Base

        def description
          "Fix blank phase on Section"
        end

        def call
          ids = ::Section.joins("LEFT OUTER JOIN phases ON phases.id = sections.phase_id")
                      .where(phases: { id: nil }).ids
          log("Destroying Section without Phase: #{ids}")
          ::Section.destroy(ids)
        end
      end
    end
  end
end
