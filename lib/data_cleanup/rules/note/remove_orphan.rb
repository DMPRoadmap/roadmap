# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank user on Answer
    module Note
      class RemoveOrphan < Rules::Base

        def description
          "Remove notes missing an answer"
        end

        def call
          ::Note.where(answer:nil).destroy_all
        end

      end
    end
  end
end
