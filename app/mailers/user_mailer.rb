# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class UserMailer < ActionMailer::Base

  prepend_view_path "app/views/branded/"

  include MailerHelper
  helper MailerHelper
  helper FeedbacksHelper

  default from: Rails.configuration.x.organisation.email

  def welcome_notification(user)
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email,
           subject: _("Welcome to %{tool_name}") % {
             tool_name: ApplicationService.application_name
           })
    end
  end

  def question_answered(data, user, answer, _options_string)
    @user = user
    @answer = answer
    @data = data
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: data["email"],
           subject: data["subject"])
    end
  end

  def sharing_notification(role, user, inviter:)
    @role    = role
    @user    = user
    @inviter = inviter
    subject  = _("A Data Management Plan in %{tool_name} has been shared "\
                   "with you") % {
                     tool_name: ApplicationService.application_name
                   }
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, subject: subject)
    end
  end

  def permissions_change_notification(role, user)
    return unless user.active?

    @role = role
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email,
           subject: _("Changed permissions on a Data Management Plan in %{tool_name}") % {
             tool_name: ApplicationService.application_name
           })
    end
  end

  def plan_access_removed(user, plan, current_user)
    return unless user.active?

    @user = user
    @plan = plan
    @current_user = current_user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email,
           subject: (_("Permissions removed on a DMP in %{tool_name}") % {
             tool_name: ApplicationService.application_name
           }).to_s)
    end
  end

  def feedback_notification(recipient, plan, requestor)
    return unless @user.org.present? && recipient.active?

    @user = requestor
    @org = @user.org
    @plan = plan
    @recipient = recipient

    FastGettext.with_locale FastGettext.default_locale do
      mail(to: recipient.email,
           subject: _("%{application_name}: %{user_name} requested feedback on a plan") % {
             application_name: ApplicationService.application_name, user_name: @user.name(false)
           })
    end
  end

  def feedback_complete(recipient, plan, requestor)
    return unless recipient.active?

    @requestor = requestor
    @user      = recipient
    @plan      = plan
    @phase     = plan.phases.first
    FastGettext.with_locale FastGettext.default_locale do
      sender = Rails.configuration.x.organisation.do_not_reply_email ||
               Rails.configuration.x.organisation.email
      mail(
        to: recipient.email,
        from: sender,
        subject: _("%{application_name}: Expert feedback has been provided for %{plan_title}") % {
          application_name: ApplicationService.application_name, plan_title: @plan.title
        }
      )
    end
  end

  def feedback_confirmation(recipient, plan, requestor)
    return unless user.org.present? && recipient.active?

    user = requestor
    org = user.org
    plan = plan

    # Use the generic feedback confirmation message unless the Org has specified one
    subject = org.feedback_email_subject || feedback_confirmation_default_subject
    message = org.feedback_email_msg || feedback_confirmation_default_message

    @body = feedback_constant_to_text(message, user, plan, org)

    FastGettext.with_locale FastGettext.default_locale do
      mail(to: recipient.email,
           subject: feedback_constant_to_text(subject, user, plan, org))
    end
  end

  def plan_visibility(user, plan)
    return unless user.active?

    @user = user
    @plan = plan
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email,
           subject: _("DMP Visibility Changed: %{plan_title}") % { plan_title: @plan.title })
    end
  end

  # commenter - User who wrote the comment
  # plan      - Plan for which the comment is associated to
  # answer - Answer commented on
  def new_comment(commenter, plan, answer)
    return unless commenter.is_a?(User) && plan.is_a?(Plan)

    owner = plan.owner
    return unless owner.present? && owner.active?

    @commenter = commenter
    @plan = plan
    @answer = answer
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: plan.owner.email, subject:
        _("%{tool_name}: A new comment was added to %{plan_title}") % {
          tool_name: ApplicationService.application_name, plan_title: plan.title
        })
    end
  end

  def admin_privileges(user)
    return unless user.active?

    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: user.email, subject:
        _("Administrator privileges granted in %{tool_name}") % {
          tool_name: ApplicationService.application_name
        })
    end
  end

  def api_credentials(api_client)
    return unless @api_client.contact_email.present?

    @api_client = api_client
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @api_client.contact_email,
           subject: _("%{tool_name} API changes") % {
             tool_name: ApplicationService.application_name
           })
    end
  end

end
# rubocop:enable Metrics/ClassLength
