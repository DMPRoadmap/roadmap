# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix missing description on QuestionFormat
    module QuestionFormat
      class FixMissingDescription < Rules::Base

        def description
          "QuestionFormat: Set the title value for the missing description"
        end

        def call
          ::QuestionFormat.where(description: ["", nil]).update_all("description=title")
        end
      end
    end
  end
end
