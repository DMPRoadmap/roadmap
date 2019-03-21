# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete answers without question
    module Answer
      class DeleteAnswersWithoutQuestion < Rules::Base

        def description
          "Answer: Delete answers without Question"
        end

        def call
          ::Answer.where(question_id: nil).delete_all()
        end
      end
    end
  end
end
