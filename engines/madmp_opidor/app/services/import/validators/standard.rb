# frozen_string_literal: true

module Import
  module Validators
    # Service used to convert plan from RDA DMP Commons Standars Format
    # to Standard Format
    class Standard
      class << self
        BAD_PLAN_MSG = _(':meta, :project and :researchOutput are required properties').freeze
        BAD_RESEARCH_OUTPUT_MSG = _('at least one researchOutput must be present').freeze
        BAD_CONTACT_MSG = _(':contact is required with a valid :mbox').freeze

        def plan_valid?(json:)
          json.present? && json['meta'].present? && json['project'].present? &&
            json['researchOutput'].present?
        end

        def research_output_valid?(json:)
          !json.blank?
        end

        def contact_valid?(json:)
          json.present? && json['person'].present? && json['person']['mbox'].present?
        end

        def validation_errors(json:)
          errs = []
          errs << BAD_PLAN_MSG unless plan_valid?(json:)
          errs << BAD_CONTACT_MSG unless contact_valid?(json: json.dig('meta', 'contact'))
          errs << BAD_RESEARCH_OUTPUT_MSG unless research_output_valid?(json: json['researchOutput'])
          errs.flatten.compact.uniq
        end
      end
    end
  end
end
