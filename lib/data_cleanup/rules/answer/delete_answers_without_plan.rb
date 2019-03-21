# frozen_string_literal: true
module DataCleanup
  module Rules
    # Delete answers without plan
    module Answer
      class DeleteAnswersWithoutPlan < Rules::Base

        def description
          "Answer: Delete answers without Plan"
        end

        def call
          ::Answer.where(plan_id: nil).destroy_all()
        end
      end
    end
  end
end
