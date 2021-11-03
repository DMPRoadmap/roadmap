# frozen_string_literal: true

module Dmptool

  module Mailer

    def invitation(inviter, invitee, plan)
      @invitee = invitee
      @plan = plan

      @inviter_type = inviter.class.name

      @inviter_email = inviter.email if inviter.is_a?(User)
      @org_email = plan.template&.org&.contact_email

      @inviter_name = inviter.name(false) if inviter.is_a?(User)
      @org_name = plan.template&.org&.name
      @client_name = inviter.description if inviter.is_a?(ApiClient)

      subject = _("A Data Management Plan in the %{application_name} has been shared with you") % {
        application_name: ApplicationService.application_name
      }
      I18n.with_locale I18n.default_locale do
        mail(to: @invitee.email, subject: subject)
      end
    end

    # Sent out to admins when a user self registers for the API via the Developer Tools' tab on Profile page
    def new_api_client(api_client)
      @api_client = api_client

      @name = @api_client.contact_name.present? ? @api_client.contact_name : @api_client.contact_email
      @name = @api_client.user.name(false) unless @name.present?
      @email = @api_client.contact_email || @api_client.user.email

      I18n.with_locale I18n.default_locale do
        mail(to: Rails.configuration.x.application.admin_emails,
            subject: _("%{tool_name} new API registration") % { tool_name: tool_name})
      end
    end

    # Sends the error message out to the administrators
    def notify_administrators(message)
      administrators = Rails.configuration.x.application.admin_emails
      return false unless administrators.present?

      @message = message

      I18n.with_locale I18n.default_locale do
        mail(to: administrators,
            subject: _("%{tool_name} error occurred") % { tool_name: tool_name })
      end
    end

    # Sends an email to the Plan's owner letting them know that the Plan was created by the ApiClient
    def new_plan_via_api(recipient:, plan:, api_client:)
      return false unless recipient.is_a?(User) && plan.is_a?(Plan) && api_client.is_a?(ApiClient)

      default_subject = _("A new data management plan (DMP) has been started for you by %{external_system_name}") % {
        external_system_name: api_client.description
      }
      subject = plan.template&.org&.api_create_plan_email_subject || default_subject

      @message = plan.template&.org&.api_create_plan_email_body
      @api_client = api_client
      @user = recipient
      @plan = plan
      I18n.with_locale I18n.default_locale do
        mail(
          to: Rails.env.production? ? recipient.email : api_client.contact_email,
          cc: plan.template.org&.contact_email,
          subject: subject
        )
      end
    end

    # Sends an email to the recipient notifying them of the new Plan created for them by
    # the sender
    def new_plan_via_template(recipient:, sender:, plan:)
      return false unless recipient.is_a?(User) && sender.is_a?(User) && plan.is_a?(Plan)

      subject = plan.template.email_subject

      @message = plan.template.email_body
      @user = recipient
      @plan = plan
      @sender = sender
      I18n.with_locale I18n.default_locale do
        mail(to: recipient.email, cc: sender.email, subject: subject)
      end
    end

  end

end