# frozen_string_literal: true

module Dmptool

  module Mailers

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
            cc: "brian.riley@ucop.edu; xsrust@gmail.com", # manuel.minwary@ucr.edu",
            subject: _("New DMP created")
          )

      # AWS SES does not allow the sender to be be from a different domain so
      # we remove the `from:` that was being used to pretendd it is coming from
      # the Org's contact_email
      def feedback_complete(recipient, plan, requestor)
        @requestor = requestor
        @user      = recipient
        @plan      = plan
        @phase     = plan.phases.first
        if recipient.active?
          FastGettext.with_locale FastGettext.default_locale do
            mail(to: recipient.email,
                 subject: _("%{application_name}: Expert feedback has been provided for %{plan_title}") % {application_name: Rails.configuration.branding[:application][:name], plan_title: @plan.title})
          end
        end
      end

    end

  end

end
