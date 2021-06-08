# frozen_string_literal: true

module Api

  module V1

    class ApiPresenter

      class << self

        def boolean_to_yes_no_unknown(value:)
          return "unknown" unless value.present?

          value ? "yes" : "no"
        end

      end

    end

  end

end
