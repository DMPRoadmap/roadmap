# frozen_string_literal: true

module Dmptool

  module Mailers

    module UserMailer

      def api_plan_creation(plan, contributor)
        return false unless contributor.present? && plan.present?

        @contributor = contributor
        @plan = plan

        FastGettext.with_locale FastGettext.default_locale do
          mail(
            to: "brian.riley@ucop.edu; manuel.minwary@ucr.edu",
            subject: _("New DMP created")
          )
        end
      end

    end

  end

end
