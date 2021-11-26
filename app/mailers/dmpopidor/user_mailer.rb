# frozen_string_literal: true

module Dmpopidor

  module UserMailer

    # commenter - User who wrote the comment
    # plan      - Plan for which the comment is associated to
    # answer - Answer commented on
    # collaborator - User to send the notification to
    # CHANGES
    # Mail is sent with user's locale
    # rubocop:disable Metrics/AbcSize
    def new_comment(commenter, plan, answer, collaborator)
      return unless commenter.is_a?(User) && plan.is_a?(Plan)

      owner = plan.owner
      return unless owner.present? && owner.active?

      @commenter       = commenter
      @commenter_name  = @commenter.name
      @plan            = plan
      @plan_title      = @plan.title
      @user_name       = @plan.owner.name
      @answer          = answer
      @question        = @answer.question
      @question_number = @question.number
      @section_title   = @question.section.title
      @phase_id        = @question.section.phase.id
      @research_output = @answer.research_output
      @research_output_name = @research_output.fullname
      @phase_link = url_for(action: "edit", controller: "plans", id: @plan.id, phase_id: @phase_id)

      I18n.with_locale current_locale(collaborator) do
        mail(to: @plan.owner.email,
             subject: _("%{tool_name}: A new comment was added to %{plan_title}") %
             {
               tool_name: tool_name,
               plan_title: @plan.title
             })
      end
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES
    # Changed subject text
    # Mail is sent with user's locale
    def sharing_notification(role, user, inviter:)
      @role       = role
      @user       = user
      @user_email = @user.email
      @username   = @user.name
      @inviter    = inviter
      @link       = url_for(action: "show", controller: "plans", id: @role.plan.id)

      I18n.with_locale current_locale(@user) do
        mail(to: @role.user.email,
             subject: _("%{user_name} has shared a Data Management Plan with you in %{tool_name}") %
             {
               tool_name: tool_name
             })
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def permissions_change_notification(role, user)
      return unless user.active?

      @role       = role
      @plan_title = @role.plan.title
      @user       = user
      @username   = @user.name
      @messaging  = role_text(@role)

      I18n.with_locale current_locale(role.user) do
        mail(to: @role.user.email,
             subject: _("Changed permissions on a Data Management Plan in %{tool_name}") %
             {
               tool_name: tool_name
             })
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def plan_access_removed(user, plan, current_user)
      return unless user.active?

      @user         = user
      @plan         = plan
      @current_user = current_user

      I18n.with_locale current_locale(@user) do
        mail(to: @user.email,
             subject: _("Permissions removed on a DMP in %{tool_name}") %
             {
               tool_name: tool_name
             })
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

      I18n.with_locale current_locale(recipient) do
        mail(to: @recipient.email,
             subject: _("%{user_name} has requested feedback on a %{tool_name} plan") %
             {
               tool_name: tool_name, user_name: @user.name(false)
             })
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    # sender is org's user contact email or no-reply
    def feedback_complete(recipient, plan, requestor)
      return unless recipient.active?

      @requestor_name = requestor.name(false)
      @user           = recipient
      @recipient_name = @user.name(false)
      @plan           = plan
      @phase          = @plan.phases.first
      @plan_name      = @plan.title

      I18n.with_locale current_locale(recipient) do
        sender = requestor.org.contact_email ||
                 Rails.configuration.x.organisation.do_not_reply_email ||
                 Rails.configuration.x.organisation.email

        mail(to: recipient.email,
             from: sender,
             subject: _("%{tool_name}: Expert feedback has been provided for %{plan_title}") %
             {
               tool_name: tool_name, plan_title: @plan.title
             })
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def plan_visibility(user, plan)
      return unless user.active?

      @user            = user
      @username        = @user.name
      @plan            = plan
      @plan_title      = @plan.title
      @plan_visibility = Plan::VISIBILITY_MESSAGE[@plan.visibility.to_sym]

      I18n.with_locale current_locale(user) do
        mail(to: @user.email,
             subject: _("DMP Visibility Changed: %{plan_title}") %
             {
               plan_title: @plan.title
             })
      end
    end

    # CHANGES
    # Mail is sent with user's locale
    def admin_privileges(user)
      return unless user.active?

      @user      = user
      @username  = @user.name
      @ul_list   = privileges_list(@user)

      I18n.with_locale current_locale(@user) do
        mail(to: user.email,
             subject: _("Administrator privileges granted in %{tool_name}") %
             {
               tool_name: tool_name
             })
      end
    end

    ##################
    ## NEW METHODS ###
    ##################
    def anonymization_warning(user)
      @user = user
      @end_date = (@user.last_sign_in_at + 5.years).to_date
      I18n.with_locale current_locale(@user) do
        mail(to: @user.email, subject:
          _("Account expiration in %{tool_name}") % { :tool_name => tool_name })
      end
    end

    def anonymization_notice(user)
      @user = user
      I18n.with_locale current_locale(@user) do
        mail(to: @user.email, subject:
          _("Account expired in %{tool_name}") % { :tool_name => tool_name })
      end
    end

    private

    def current_locale(user)
      user.get_locale.nil? ? I18n.default_locale : user.get_locale
    end

  end

end
