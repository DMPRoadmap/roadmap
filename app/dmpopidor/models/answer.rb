# frozen_string_literal: true

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
        return false unless question.present?
        # If the question is option based then see if any options were selected
        return question_options.any? if question.question_format.option_based?

        if question.question_format.structured
          return !madmp_fragment.nil? || madmp_fragment.data.nil? || madmp_fragment.data.compact.empty?
        end
        # Strip out any white space and see if the text is empty
        return !text.gsub(%r{</?p>}, "").gsub(%r{<br\s?/?>}, "").chomp.blank? if text.present?
      end

      def age
        return unless question.present?

        return madmp_fragment.updated_at.iso8601 if question.question_format.structured

        updated_at.iso8601
      end

    end

  end

end
