# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix question where number not unique on Question
    module Question
      class FixQuestionWhereNumberNotUnique < Rules::Base

        def description
          "Question: Reorder questions in section, where number(order) is not unique"
        end

        def call
          invalid_questions = ::Question.all.reject(&:valid?)
          # Get the sections associated to the invalid questions
          sections = ::Section.where(id: invalid_questions.collect(&:section_id).uniq)

          sections.each do |s| 
            # Get associated questions, order by number
            qs = s.questions.order(:number)

            # Reorder questions
            qs.each_with_index do |q, idx|
              q.update_attribute('number', idx + 1)
            end
          end

        end
      end
    end
  end
end
