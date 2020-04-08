# frozen_string_literal: true

module Dmptool

  module Mailer

    module UserMailer

      def api_plan_creation(plan, contributor)
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
