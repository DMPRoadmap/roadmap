# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Note
    module User
      class FixBlankOrg < Rules::Base

        def description
          "Fix blank Org on User"
        end

        def call
          users = ::User.joins("LEFT OUTER JOIN orgs ON orgs.id = users.org_id")
                      .where(orgs: { id: nil })
          log("Setting users without orgs to other_org: #{users.map(&:id)}")
          users.update_all(org_id: ::Org.where(is_other: true).first.id)
        end
      end
    end
  end
end
