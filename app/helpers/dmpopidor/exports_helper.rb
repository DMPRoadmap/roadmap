# frozen_string_literal: true

module Dmpopidor
  # Customized code for ExportsHelper
  module ExportsHelper
    # Changed label
    def plan_attribution(attribution)
      attribution = Array(attribution)
      prefix = attribution.many? ? _('DMP Creators:') : _('DMP Creator:')
      "<strong>#{prefix}</strong> #{attribution.join(', ')}"
    end

    def should_hide_question(question, research_output)
      if question[:madmp_schema].classname === 'personal_data_issues'
        return research_output.has_personal_data === false
      end
      return false
    end

  end
end
