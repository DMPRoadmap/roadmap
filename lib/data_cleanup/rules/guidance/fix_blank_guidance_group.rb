# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank guidance_group on Guidance
    module Guidance
      class FixBlankGuidanceGroup < Rules::Base

        def description
          "Fix blank guidance_group on Guidance"
        end

        def call
          ids = ::Guidance.joins("LEFT OUTER JOIN guidance_groups ON guidance_groups.id = guidances.guidance_group_id")
                      .where(guidance_groups: { id: nil }).ids
          log("Destroying Guidance without GuidanceGroup: #{ids}")
          ::Guidance.destroy(ids)
        end
      end
    end
  end
end
