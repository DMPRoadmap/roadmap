# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Answer
      class FixBlankQuestion < Rules::Base

        def description
          "Fix blank question on Answer"
        end

        def call
          ::Answer.where.not(question_id: ::Question.all.collect(&:id)).each do |answer|
            unless answer.question.present?
              log("Destroying orphaned Answer##{answer.id}")
              answer.destroy
            end
          end
        end

      end
    end

  end
end