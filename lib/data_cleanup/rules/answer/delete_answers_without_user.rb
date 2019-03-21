# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete answers without user
    module Answer
      class DeleteAnswersWithoutUser < Rules::Base

        def description
          "Answer : Delete answers without User"
        end

        def call
          ::Answer.where(user_id: nil).destroy_all()
        end
      end
    end
  end
end
