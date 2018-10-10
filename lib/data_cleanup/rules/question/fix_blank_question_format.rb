# frozen_string_literal: true
module DataCleanup
  module Rules
    # Fix blank question_format on Question
    module Question
      class FixBlankQuestionFormat < Rules::Base

        def description
          "Fix blank question_format on Question"
        end

        def call
          text_area = ::QuestionFormat.where("lower(title) = 'text area")
          ::Question.joins("LEFT OUTER JOIN question_formats ON question_formats.id = questions.question_format_id")
                      .where(question_formats: { id: nil }).each do |question|
            log("Defaulting Question with missing QuestionFormat to TextArea: #{ids}")

            question.update_attributes(question_format: text_area)
          end
        end
      end
    end
  end
end
