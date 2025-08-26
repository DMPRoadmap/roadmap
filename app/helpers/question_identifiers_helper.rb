# frozen_string_literal: true

# Helper methods for Question Identifiers
module QuestionIdentifiersHelper
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def find_question_id_template(id)
        template = Template.find(id)

    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end