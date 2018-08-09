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
          ::UserIdentifier.where(user: nil).destroy_all
        end
      end
    end
  end
end
