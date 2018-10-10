# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank section on Question
    module Question
      class FixBlankSection < Rules::Base

        def description
          "Fix blank section on Question"
        end

        def call
          ids = ::Question.joins("LEFT OUTER JOIN sections ON sections.id = questions.section_id")
                      .where(sections: { id: nil }).ids
          log("Destroying Question without Section: #{ids}")
          ::Question.destroy(ids)
        end
      end
    end
  end
end
