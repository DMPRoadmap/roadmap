# frozen_string_literal: true

module Mailers

  module Dmptool

    module UserMailer

      def api_plan_creation(plan, contributor)
        return false unless contributor.present? && plan.present?

        @contributor = contributor
        @plan = plan
        to_addr = @plan.api_client.contact_email
        to_addr = "brian.riley@ucop.edu" unless to_addr.present?

        FastGettext.with_locale FastGettext.default_locale do
          mail(
            to: to_addr,
            bcc: "brian.riley@ucop.edu;", # manuel.minwary@ucr.edu",
            subject: _("New DMP created")
          )
        end
      end

    end

  end

end
