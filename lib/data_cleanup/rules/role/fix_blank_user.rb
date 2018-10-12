# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank plan on Role
    module Role
      class FixBlankUser < Rules::Base

        def description
          "Fix blank user on Role"
        end

        def call
          ids = ::Role.joins("LEFT OUTER JOIN users ON users.id = roles.user_id")
                      .where(users: { id: nil }).ids
          log("Destroying Roles without User: #{ids}")
          ::Role.destroy(ids)
        end
      end
    end
  end
end
