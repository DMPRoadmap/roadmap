# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank org on OrgIdentifier
    module OrgIdentifier
      class FixBlankOrg < Rules::Base

        def description
          "Fix blank org on OrgIdentifier"
        end

        def call
          ids = ::OrgIdentifier.joins("LEFT OUTER JOIN orgs ON orgs.id = org_identifiers.org_id")
                      .where(orgs: { id: nil }).ids
          log("Destroying OrgIdentifier without Org: #{ids}")
          ::OrgIdentifier.destroy(ids)
        end
      end
    end
  end
end
