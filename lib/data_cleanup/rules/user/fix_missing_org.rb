# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing org on User
    module User
      class FixMissingOrg < Rules::Base

        def description
          "User: Link users without orgs to the other org"
        end

        def call
          ::User.where(org_id: nil).update_all({org_id: ::Org.find_by(is_other: true).id})
        end
      end
    end
  end
end
