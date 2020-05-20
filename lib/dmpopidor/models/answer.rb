module Dmpopidor
  module Models
    module Answer
      # If the answer's question is option_based, it is checked if exist any question_option
      # selected. For non option_based (e.g. textarea or textfield), it is checked the
      # presence of text
      #
      # Returns Boolean
      # CHANGES  : ADDED Structured Formart Support
      def answered?
        if question.present?
          if question.question_format.option_based?
            return question_options.any?
          elsif question.question_format.structured
            return !structured_answer.nil?
          else  # (e.g. textarea or textfield question formats)
            return not(is_blank?)
          end
        end
        false
      end



      def age
        if question.present?
          if question.question_format.structured
            return structured_answer.updated_at.iso8601
          else
            updated_at.iso8601
          end
        end
      end

    end 
  end
end