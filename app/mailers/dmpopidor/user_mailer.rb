# frozen_string_literal: true

module Dmpopidor
  # rubocop:disable Metrics/ModuleLength
  # Customized mailer code
  module UserMailer
    # commenter - User who wrote the comment
    # plan      - Plan for which the comment is associated to
    # answer - Answer commented on
    # collaborator - User to send the notification to
    # CHANGES
    # Mail is sent with user's locale
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def new_comment(commenter, plan, answer, collaborator)
      return unless commenter.is_a?(User) && plan.is_a?(Plan)

      owner = plan.owner
      return unless owner.present? && owner.active?

      @commenter       = commenter
      @commenter_name  = @commenter.name
      @plan            = plan
      @plan_title      = @plan.title
      @answer          = answer
      @question        = @answer.question
      @question_number = @question.number
      @section_title   = @question.section.title
      @phase_id        = @question.section.phase.id
      research_output  = @answer.research_output
      research_output_description = research_output&.json_fragment&.research_output_description
      @research_output_name = research_output_description.data['title']
      @phase_link = url_for(action: 'edit', controller: 'plans', id: @plan.id, phase_id: @phase_id)
      @helpdesk_email = helpdesk_email(org: @commenter.org)

      I18n.with_locale current_locale(collaborator) do
        @user_name = collaborator.name
        mail(to: collaborator.email,
             subject: format(_('%{tool_name}: A new comment was added to %{plan_title}'), tool_name: tool_name,
                                                                                          plan_title: @plan.title))
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES
    # Changed subject text
    # Mail is sent with user's locale
    # rubocop:disable Metrics/AbcSize
    def sharing_notification(role, user, inviter:)
      @role       = role
      @user       = user
      @user_email = @user.email
      @username   = @user.name
      @inviter    = inviter
      @link       = url_for(action: 'show', controller: 'plans', id: @role.plan.id)
      @helpdesk_email = helpdesk_email(org: @user.org)

      I18n.with_locale current_locale(@user) do
        mail(to: @role.user.email,
             subject: format(_('%{user_name} has shared a Data Management Plan with you in %{tool_name}'),
                             user_name: @inviter.name(false), tool_name: tool_name))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES
    # Mail is sent with user's locale
    # rubocop:disable Metrics/AbcSize
    def permissions_change_notification(role, user)
      return unless user.active?

      @role       = role
      @plan_title = @role.plan.title
      @user       = user
      @recepient  = @role.user
      @messaging  = role_text(@role)
      @helpdesk_email = helpdesk_email(org: @user.org)

      I18n.with_locale current_locale(role.user) do
        mail(to: @role.user.email,
             subject: format(_('Changed permissions on a Data Management Plan in %{tool_name}'), tool_name: tool_name))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES
    # Mail is sent with user's locale
    def plan_access_removed(user, plan, current_user)
      return unless user.active?

      @user         = user
      @plan         = plan
      @current_user = current_user
      @helpdesk_email = helpdesk_email(org: @plan.org)

      I18n.with_locale current_locale(@user) do
        mail(to: @user.email,
             subject: format(_('Permissions removed on a DMP in %{tool_name}'), tool_name: tool_name))
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def feedback_notification(recipient, plan, requestor)
      return unless recipient.active?

      @user           = requestor
      @plan           = plan
      @recipient      = recipient
      @recipient_name = @recipient.name(false)
      @requestor_name = @user.name(false)
      @plan_name      = @plan.title
      @helpdesk_email = helpdesk_email(org: @plan.org)

      I18n.with_locale current_locale(recipient) do
        mail(to: @recipient.email,
             subject: format(_('%{user_name} has requested feedback on a %{tool_name} plan'),
                             tool_name: tool_name, user_name: @user.name(false)))
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    # sender is org's user contact email or no-reply
    # rubocop:disable Metrics/AbcSize
    def feedback_complete(recipient, plan, requestor)
      return unless recipient.active?

      @requestor_name = requestor.name(false)
      @user           = recipient
      @recipient_name = @user.name(false)
      @plan           = plan
      @phase          = @plan.phases.first
      @plan_name      = @plan.title
      @helpdesk_email = helpdesk_email(org: @plan.org)

      I18n.with_locale current_locale(recipient) do
        sender = Rails.configuration.x.organisation.do_not_reply_email ||
                 Rails.configuration.x.organisation.email

        mail(to: recipient.email,
             from: sender,
             subject: format(_('%{tool_name}: Expert feedback has been provided for %{plan_title}'),
                             tool_name: tool_name, plan_title: @plan.title))
      end
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES
    # Mail is sent with user's locale
    def plan_visibility(user, plan)
      return unless user.active?

      @user            = user
      @username        = @user.name
      @plan            = plan
      @plan_title      = @plan.title
      @plan_visibility = ::Plan::VISIBILITY_MESSAGE[@plan.visibility.to_sym]
      @helpdesk_email = helpdesk_email(org: @plan.org)

      I18n.with_locale current_locale(user) do
        mail(to: @user.email,
             subject: format(_('DMP Visibility Changed: %{plan_title}'), plan_title: @plan.title))
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def admin_privileges(user)
      return unless user.active?

      @user      = user
      @username  = @user.name
      @ul_list   = privileges_list(@user)
      @helpdesk_email = helpdesk_email(org: @user.org)

      I18n.with_locale current_locale(@user) do
        mail(to: user.email,
             subject: format(_('Administrator privileges granted in %{tool_name}'), tool_name: tool_name))
      end
    end

    # rubocop:disable Metrics/AbcSize
    def api_credentials(api_client)
      @api_client = api_client
      return unless @api_client.contact_email.present?

      @api_docs = Rails.configuration.x.application.api_documentation_urls[:v1]

      @name = @api_client.contact_name.present? ? @api_client.contact_name : @api_client.contact_email

      @helpdesk_email = helpdesk_email(org: @api_client.org)

      I18n.with_locale I18n.default_locale do
        mail(to: @api_client.contact_email,
             subject: format(_('%{tool_name} API client created/updated'), tool_name: tool_name))
      end
    end
    # rubocop:enable Metrics/AbcSize

    ##################
    ## NEW METHODS ###
    ##################
    def anonymization_warning(user)
      @user = user
      @end_date = (@user.last_sign_in_at + 5.years).to_date
      @helpdesk_email = helpdesk_email(org: @user.org)
      I18n.with_locale current_locale(@user) do
        mail(to: @user.email, subject:
          format(_('Account expiration in %{tool_name}'), tool_name: tool_name))
      end
    end

    def anonymization_notice(user)
      @user = user
      @helpdesk_email = helpdesk_email(org: @user.org)
      I18n.with_locale current_locale(@user) do
        mail(to: @user.email, subject:
          format(_('Account expired in %{tool_name}'), tool_name: tool_name))
      end
    end

    private

    def current_locale(user)
      user.locale.nil? ? I18n.default_locale : user.locale
    end
  end
  # rubocop:enable Metrics/ModuleLength
end
