# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix duplicate question on Answer
    module Answer
      class FixDuplicateQuestion < Rules::Base

        def description
          "Fix duplicate question on Answer"
        end

        def call
          # Take all answers that have duplicate question/plan combo...
          dataset = ::Answer.group(:question_id, :plan_id)
                            .count.select { |k,v| v > 1 }
          # Values looks like [{ [123, 199] => 2}, ...]
          dataset.each do |values, count|
            # ... and destroy all duplicates, keeping the latest record
            ::Answer.where(question: values.first, plan_id: values.last)
                    .order("created_at DESC")
                    .offset(1)
                    .destroy_all
          end
        end
      end
    end
  end
end
