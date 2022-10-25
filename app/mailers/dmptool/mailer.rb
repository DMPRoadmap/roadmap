# frozen_string_literal: true

module Dmptool
  # DMPTool specific mailers
  module Mailer
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def invitation(inviter, invitee, plan)
      @invitee = invitee
      @plan = plan

      @inviter_type = inviter.class.name

      @inviter_email = inviter.email if inviter.is_a?(User)
      @org_email = plan.template&.org&.contact_email

      @inviter_name = inviter.name(false) if inviter.is_a?(User)
      @org_name = plan.template&.org&.name
      @client_name = inviter.description if inviter.is_a?(ApiClient)

      subject = format(_('A Data Management Plan in the %{application_name} has been shared with you'),
                       application_name: ApplicationService.application_name)
      I18n.with_locale I18n.default_locale do
        mail(to: @invitee.email, subject: subject)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # Sent out to admins when a user self registers for the API via the Developer Tools' tab on Profile page
    # rubocop:disable Metrics/AbcSize
    def new_api_client(api_client)
      @api_client = api_client

      @name = (@api_client.contact_name.presence || @api_client.contact_email)
      @name = @api_client.user.name(false) if @name.blank?
      @email = @api_client.contact_email || @api_client.user.email

      I18n.with_locale I18n.default_locale do
        mail(to: Rails.configuration.x.application.admin_emails,
             subject: format(_('%{tool_name} new API registration'), tool_name: tool_name))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # Sends the error message out to the administrators
    def notify_administrators(message)
      administrators = Rails.configuration.x.application.admin_emails
      return false if administrators.blank?

      @message = message

      I18n.with_locale I18n.default_locale do
        mail(to: administrators,
             subject: format(_('%{tool_name} error occurred'), tool_name: tool_name))
      end
    end

    # Sends an email to the Plan's owner letting them know that the Plan was created by
    # the ApiClient
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def new_plan_via_api(recipient:, plan:, api_client:)
      return false unless recipient.is_a?(User) && plan.is_a?(Plan) && api_client.is_a?(ApiClient)

      dflt = _('A new data management plan (DMP) has been started for you by %{external_system_name}')
      subject = plan.template&.org&.api_create_plan_email_subject || dflt

      @message = plan.template&.org&.api_create_plan_email_body
      @api_client = api_client
      @user = recipient
      @plan = plan
      I18n.with_locale I18n.default_locale do
        mail(
          to: Rails.env.production? ? recipient.email : api_client.contact_email,
          cc: plan.template.org&.contact_email,
          subject: format(subject, external_system_name: api_client.description)
        )
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

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
