# frozen_string_literal: true

module Api
  module V2
    # Helper methods for research outputs
    class ResearchOutputPresenter
      attr_reader :dataset_id, :preservation_statement, :security_and_privacy, :license_start_date,
                  :data_quality_assurance, :distributions, :metadata, :technical_resources

      def initialize(output:)
        @research_output = output
        return unless output.is_a?(ResearchOutput)

        @plan = output.plan
        @dataset_id = identifier

        load_narrative_content

        @license_start_date = determine_license_start_date(output: output)
      end

      private

      def identifier
        Identifier.new(identifiable: @research_output, value: @research_output.id)
      end

      def determine_license_start_date(output:)
        return nil unless output.present?
        return output.release_date.to_formatted_s(:iso8601) if output.release_date.present?

        output.created_at.to_formatted_s(:iso8601)
      end

      def load_narrative_content
        @preservation_statement = ''
        @security_and_privacy = []
        @data_quality_assurance = ''

        # Disabling rubocop here since a guard clause would make the line too long
        # rubocop:disable Style/GuardClause
        if Rails.configuration.x.madmp.extract_preservation_statements_from_themed_questions
          @preservation_statement = fetch_q_and_a_as_single_statement(themes: %w[Preservation])
        end
        if Rails.configuration.x.madmp.extract_security_privacy_statements_from_themed_questions
          @security_and_privacy = fetch_q_and_a(themes: ['Ethics & privacy', 'Storage & security'])
        end
        if Rails.configuration.x.madmp.extract_data_quality_statements_from_themed_questions
          @data_quality_assurance = fetch_q_and_a_as_single_statement(themes: ['Data Collection'])
        end
        # rubocop:enable Style/GuardClause
      end

      def fetch_q_and_a_as_single_statement(themes:)
        fetch_q_and_a(themes: themes).collect { |item| item[:description] }.join('<br>')
      end

      def fetch_q_and_a(themes:)
        return [] unless themes.is_a?(Array) && themes.any?

        answers = answers_for_themes(themes)

        descs_by_theme = build_descriptions_by_theme_hash(answers, themes)

        descs_by_theme.map do |theme, descs|
          { title: theme, description: descs }
        end
      end

      def answers_for_themes(themes)
        @plan.answers
             .joins(question: :themes)
             .where(themes: { title: themes })
             .includes(question: :themes)
             .distinct
      end

      def build_descriptions_by_theme_hash(answers, themes)
        descs_by_theme = Hash.new { |h, k| h[k] = [] }

        answers.each do |answer|
          answer.question.themes.each do |theme|
            next unless themes.include?(theme.title)

            descs_by_theme[theme.title] << format_q_and_a(answer.question, answer)
          end
        end
        descs_by_theme
      end

      def format_q_and_a(question, answer)
        "<strong>Question:</strong> #{question.text}<br><strong>Answer:</strong> #{answer.text}"
      end
    end
  end
end
