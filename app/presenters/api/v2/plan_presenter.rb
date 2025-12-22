# frozen_string_literal: true

module Api
  module V2
    # Helper class for the API V2 project / DMP
    class PlanPresenter
      attr_reader :data_contact, :contributors, :costs

      def initialize(plan:)
        @contributors = []
        return unless plan.present?

        @plan = plan

        @data_contact = @plan.owner

        # Attach the first data_curation role as the data_contact, otherwise
        # add the contributor to the contributors array
        @plan.contributors.each do |contributor|
          @data_contact = contributor if contributor.data_curation? && @data_contact.nil?
          @contributors << contributor
        end

        @costs = plan_costs(plan: @plan)
      end

      # Extract the ARK or DOI for the DMP OR use its URL if none exists
      def identifier
        doi = @plan.identifiers.select do |id|
          ::Plan::DMP_ID_TYPES.include?(id.identifier_format)
        end
        return doi.first if doi.first.present?

        # if no DOI then use the URL for the API's 'show' method
        Identifier.new(value: Rails.application.routes.url_helpers.api_v2_plan_url(@plan))
      end

      # Fetch all questions and answers from a plan, regardless of theme
      def fetch_all_q_and_a(plan:) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
        return [] unless plan&.questions.present?

        plan.questions.filter_map do |q|
          a = plan.answers.find { |ans| ans.question_id == q.id }
          next unless a.present? && !a.blank?

          {
            title: "Question #{q.number || q.id}",
            question: q.text.to_s,
            answer: a.text.to_s
          }
        end
      end

      private

      # Retrieve the answers that have the Budget theme
      def plan_costs(plan:)
        theme = Theme.where(title: 'Cost').first
        return [] unless theme.present?

        # TODO: define a new 'Currency' question type that includes a float field
        #       any currency type selector (e.g GBP or USD)
        answers = plan.answers.includes(question: :themes).select do |answer|
          answer.question.themes.include?(theme)
        end

        answers.map do |answer|
          # TODO: Investigate whether question level guidance should be the description
          { title: answer.question.text, description: nil,
            currency_code: 'usd', value: answer.text }
        end
      end
    end
  end
end
