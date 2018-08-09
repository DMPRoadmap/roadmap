# frozen_string_literal: true
module DataCleanup
  module Rules
    module GuidanceGroup
      # Fix blank published on GuidanceGroup
      class FixBlankPublished < Rules::Base

        def description
          "Fix blank published on GuidanceGroup"
        end

        def call
          ::GuidanceGroup.where(published: nil).update_all(published: false)
        end
      end
    end
  end
end
