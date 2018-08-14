# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on UserIdentifier
    module UserIdentifier
      class FixBlankUser < Rules::Base

        def description
          "Fix UserIdentifier records with no User"
        end

        def call
          ids = ::UserIdentifier.where(user: nil).ids
          log("Destroying UserIdentifier where ids: #{ids} (no user)")
          ::UserIdentifier.destroy(ids)
        end
      end
    end
  end
end
