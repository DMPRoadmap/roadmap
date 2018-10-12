# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank org on GuidanceGroup
    module GuidanceGroup
      class FixBlankOrg < Rules::Base

        def description
          "Fix blank org on GuidanceGroup"
        end

        def call
          ids = ::GuidanceGroup.joins("LEFT OUTER JOIN orgs ON orgs.id = guidance_groups.org_id")
                      .where(orgs: { id: nil }).ids
          log("Destroying GuidanceGroup without Org: #{ids}")
          ::GuidanceGroup.destroy(ids)
        end
      end
    end
  end
end
