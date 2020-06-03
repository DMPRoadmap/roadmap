# frozen_string_literal: true

module Dmptool

  module Mailers

    module UserMailer

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
