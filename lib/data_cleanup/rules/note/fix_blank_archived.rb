# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank archived on Note
    module Note
      class FixBlankArchived < Rules::Base

        def description
          "Fix blank archived on Note"
        end

        def call
          ::Note.where(archived: nil).update_all(archived: false)
        end
      end
    end
  end
end
