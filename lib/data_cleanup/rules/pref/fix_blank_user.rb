# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Pref
    module Pref
      class FixBlankUser < Rules::Base

        def description
          "Fix blank user on Pref"
        end

        def call
          ids = ::Pref.joins("LEFT OUTER JOIN users ON users.id = prefs.user_id")
                      .where(users: { id: nil }).ids
          log("Destroying Pref without User: #{ids}")
          ::Pref.destroy(ids)
        end
      end
    end
  end
end
