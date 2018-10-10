# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module GuidanceGroup
      class RemoveBlankOrg < Rules::Base

        def description
          "Remove GuidanceGroups without an org (and any orphaned guidances)"
        end

        def call
          ::GuidanceGroup.where(org: nil).each do |group|
            group.guidances.destroy_all
            group.destroy
          end
        end

      end
    end
  end
end
