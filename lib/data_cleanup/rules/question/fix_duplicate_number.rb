# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix duplicate number on Question
    module Question
      class FixDuplicateNumber < Rules::Base

        def description
          "Fix duplicate number on Question"
        end

        def call
          data = ::Question.group(:number, :section_id)
                           .count
                           .select { |k,v| v > 1 }
          data.each do |values, count|
            number, section_id = *values
            ids = ::Question.where(section_id: section_id)
                         .order("number ASC, created_at ASC")
                         .pluck(:id)
            section = ::Section.find(section_id)
            ::Question.update_numbers!(*ids, parent: section)
          end
        end
      end
    end
  end
end
