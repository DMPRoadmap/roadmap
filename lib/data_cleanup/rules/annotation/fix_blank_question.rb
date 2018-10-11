# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank question on Annotation
    module Annotation
      class FixBlankQuestion < Rules::Base

        def description
          "Fix blank question on Annotation"
        end

        def call
          ids = ::Annotation.joins("LEFT OUTER JOIN questions ON questions.id = annotations.question_id")
                      .where(questions: { id: nil }).ids
          log("Destroying Annotation without Question: #{ids}")
          ::Annotation.destroy(ids)
        end
      end
    end
  end
end
