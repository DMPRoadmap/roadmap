# frozen_string_literal: true

module Api

  module V1

    class FundingPresenter

      class << self

        # If the plan has a grant number then it has been awarded/granted
        # otherwise it is 'planned'
        def status(plan:)
          return "planned" unless plan.present?

          case plan.funding_status
          when "funded"
            "granted"
          when "denied"
            "rejected"
          else
            "planned"
          end
        end

      end

    end

  end

end
