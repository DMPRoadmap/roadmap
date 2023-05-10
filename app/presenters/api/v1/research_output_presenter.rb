# frozen_string_literal: true

module Api
  module V1
    # Helper methods for research outputs
    class ResearchOutputPresenter
      attr_reader :dataset_id, :preservation_statement, :security_and_privacy, :license_start_date,
                  :data_quality_assurance, :distributions, :metadata, :technical_resources,
                  :research_output_type

      def initialize(output:)
        @research_output = output
        return unless output.is_a?(ResearchOutput)

        @plan = output.plan
        @dataset_id = identifier

        # The DMPHub only recognizes the DEFAULT research_output_types, so use 'other' if these
        # are custom types added by an admin
        use_other = !ResearchOutput::DEFAULT_OUTPUT_TYPES.include?(output.research_output_type)
        @research_output_type = use_other ? 'other' : output.research_output_type

        load_narrative_content

        @license_start_date = determine_license_start_date(output: output)
      end

      private

      def identifier
        Identifier.new(identifiable: @research_output, value: @research_output.id)
      end

      def determine_license_start_date(output:)
        return nil if output.blank?
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
        fetch_q_and_a(themes: themes).pluck(:description).join('<br>')
      end

      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def fetch_q_and_a(themes:)
        return [] unless themes.is_a?(Array) && themes.any?

        ret = themes.map do |theme|
          qs = @plan.questions.select { |q| q.themes.collect(&:title).include?(theme) }
          descr = qs.map do |q|
            a = @plan.answers.find { |ans| ans.question_id = q.id }
            next unless a.present? && !a.blank?

            "<strong>Question:</strong> #{q.text}<br><strong>Answer:</strong> #{a.text}"
          end
          { title: theme, description: descr }
        end
        ret.select { |item| item[:description].present? }
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    end
  end
end
