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
        if question.present?
          if question.question_format.option_based?
            return question_options.any?
          elsif question.question_format.structured
            return !madmp_fragment.nil?
          else  # (e.g. textarea or textfield question formats)
            return not(is_blank?)
          end
        end
        false
      end

      def age
        if question.present?
          if question.question_format.structured
            return madmp_fragment.updated_at.iso8601
          else
            updated_at.iso8601
          end
        end
      end

      def is_blank?
        if madmp_fragment.present?
          return madmp_fragment.data.nil? || madmp_fragment.data.compact.empty?
        end
        if text.present?
          return text.gsub(/<\/?p>/, "").gsub(/<br\s?\/?>/, "").chomp.blank?
        end
        # no text so blank
        true
      end

    end

  end

end
