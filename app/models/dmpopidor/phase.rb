# frozen_string_literal: true

module Dmpopidor
  # Customized code for Phase model
  module Phase
    # CHANGES : ADDED RESEARCH OUTPUT SUPPORT
    # rubocop:disable Lint/UnusedMethodArgument
    def visibility_allowed?(plan)
      true
    end
    # rubocop:enable Lint/UnusedMethodArgument
  end
end
