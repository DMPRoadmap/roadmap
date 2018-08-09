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
          ::Answer.joins("LEFT OUTER JOIN users ON users.id = answers.user_id")
                  .where(users: { id: nil })
                  .includes(plan: { roles: :user }).each do |answer|
            log("Updating Answer##{answer.id} with user: #{answer.plan.owner}")
            answer.update(user: answer.plan.owner)
          end
        end

      end
    end
  end
end
