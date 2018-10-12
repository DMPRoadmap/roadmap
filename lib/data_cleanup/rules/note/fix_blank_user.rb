# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Note
    module Note
      class FixBlankUser < Rules::Base

        def description
          "Fix blank user on Note"
        end

        def call
          ids = ::Note.joins("LEFT OUTER JOIN users ON users.id = notes.user_id")
                      .where(users: { id: nil }).ids
          log("Destroying Note without User: #{ids}")
          ::Note.destroy(ids)
        end
      end
    end
  end
end
