# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank description on QuestionFormat
    module QuestionFormat
      class FixBlankDescription < Rules::Base

        def description
          "Fix blank description on QuestionFormat"
        end

        def call
          ::QuestionFormat.where(description: "").each do |qf|
            log("Adding default description to QuestionFormat##{qf.id}")
            qf.update!(description: "#{qf.title} format")
          end
        end
      end
    end
  end
end
