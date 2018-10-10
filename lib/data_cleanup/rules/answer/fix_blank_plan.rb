# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Answer
      class FixBlankPlan < Rules::Base

        def description
          "Fix blank plan on Answer"
        end

        def call
          ::Answer.joins("LEFT OUTER JOIN plans ON plans.id = answers.plan_id")
                  .where(plans: { id: nil }).each do |answer|
              log("Destroying orphaned Answer##{answer.id}")
              answer.destroy
            
          end

        end

      end
    end
  end
end
