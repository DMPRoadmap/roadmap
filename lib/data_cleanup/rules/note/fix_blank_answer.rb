# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank answer on Note
    module Note
      class FixBlankAnswer < Rules::Base

        def description
          "Fix blank answer on Note"
        end

        def call
          ids = ::Note.joins("LEFT OUTER JOIN answers ON answers.id = notes.answer_id")
                      .where(answers: { id: nil }).ids
          log("Destroying Note without Answer: #{ids}")
          ::Note.destroy(ids)
        end
      end
    end
  end
end
