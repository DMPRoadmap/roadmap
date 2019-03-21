# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete User Identifier without User
    module UserIdentifier
      class DeleteUserIdentifierWithoutUser < Rules::Base

        def description
          "User: Deletes the UserIdentifiers without a linked User"
        end

        def call
          ::UserIdentifier.where(user_id: nil).delete_all()
        end
      end
    end
  end
end
