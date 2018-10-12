# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank plan on Answer
    module Answer
      class FixBlankPlan < Rules::Base

        def description
          "Fix blank plan on Answer"
        end

        def call
          ::Answer.includes(:plan).all.each do |answer|
            unless answer.plan.present?
              log("Destroying orphaned Answer##{answer.id}")
              answer.destroy
            end
          end
        end

      end
    end
  end
end
