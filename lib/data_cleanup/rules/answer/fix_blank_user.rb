# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Answer
      class FixBlankUser < Rules::Base

        def description
          "Fix blank user on Answer"
        end

        def call
          ::Answer.where(user: nil)
                  .includes(plan: { roles: :user })
                  .find_in_batches do |answers|

            answers.each do |answer|
              log("Updating Answer##{answer.id} with user: #{user.plan.owner}")
              answer.update(user: answer.plan.owner)
            end
          end
        end

      end
    end
  end
end
