# frozen_string_literal: true

module Api

  module V1

    class ResearchOutputPresenter

      attr_reader :dataset_id, :preservation_statement, :security_and_privacy, :license_start_date,
                  :data_quality_assurance, :distributions, :metadata, :technical_resources

      def initialize(output:)
        @research_output = output
        return unless output.is_a?(ResearchOutput)

        @plan = output.plan
        @dataset_id = identifier
        @preservation_statement = fetch_q_and_a_as_single_statement(themes: %w[Preservation])
        @security_and_privacy = fetch_q_and_a(themes: ["Ethics & privacy", "Storage & security"])
        @data_quality_assurance = fetch_q_and_a_as_single_statement(themes: ["Data Collection"])
        @license_start_date = output.release_date&.to_formatted_s(:iso8601) if output.release_date.present?
        @license_start_date = output.created_at&.to_formatted_s(:iso8601) unless @license_start_date.present?
      end

      private

      def identifier
        Identifier.new(identifiable: @research_output, value: @research_output.id)
      end

      def fetch_q_and_a_as_single_statement(themes:)
        fetch_q_and_a(themes: themes).collect { |item| item[:description] }.join("<br>")
      end

      # rubocop:disable Metrics/AbcSize
      def fetch_q_and_a(themes:)
        return [] unless themes.is_a?(Array) && themes.any?

        ret = themes.map do |theme|
          qs = @plan.questions.select { |q| q.themes.collect(&:title).include?(theme) }
          descr = qs.map do |q|
            a = @plan.answers.select { |ans| ans.question_id = q.id }.first
            next unless a.present? && !a.blank?

            "<strong>Question:</strong> #{q.text}<br><strong>Answer:</strong> #{a.text}"
          end
          { title: theme, description: descr }
        end
        ret.select { |item| item[:description].present? }
      end
      # rubocop:enable Metrics/AbcSize

    end

  end

end
