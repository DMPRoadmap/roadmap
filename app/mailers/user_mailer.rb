class UserMailer < ActionMailer::Base
  prepend Dmpopidor::Mailers::UserMailer
  include MailerHelper
  helper MailerHelper
  helper FeedbacksHelper

  default from: Rails.configuration.branding[:organisation][:email]

  def welcome_notification(user)
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email,
           subject: _('Welcome to %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end

  def sharing_notification(role, user, inviter:)
    @role = role
    @user = user
    @inviter = inviter

    FastGettext.with_locale current_locale(@user) do
      subject  = d_('dmpopidor', '%{user_name} has shared a Data Management Plan with you in %{tool_name}') % {
        :user_name => @inviter.name(false),
        :tool_name => Rails.configuration.branding[:application][:name]
       }
      mail(to: @role.user.email, subject: subject)
    end
  end

  def permissions_change_notification(role, user)
    @role = role
    @user = user
    if user.active?
      FastGettext.with_locale current_locale(role.user) do
        mail(to: @role.user.email,
             subject: _('Changed permissions on a Data Management Plan in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
      end
    end
  end

  def plan_access_removed(user, plan, current_user)
    @user = user
    @plan = plan
    @current_user = current_user
    if user.active?
      FastGettext.with_locale current_locale(@user) do
        mail(to: @user.email,
             subject: "#{_('Permissions removed on a DMP in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] }}")
      end
    end
  end

  def feedback_notification(recipient, plan, requestor)
    @user = requestor

    if @user.org.present? && recipient.active?
      @org = @user.org
      @plan = plan
      @recipient = recipient

      FastGettext.with_locale current_locale(recipient) do
        mail(to: recipient.email,
             subject: _("%{application_name}: %{user_name} requested feedback on a plan") % {application_name: Rails.configuration.branding[:application][:name], user_name: @user.name(false)})
      end
    end
  end

  def feedback_complete(recipient, plan, requestor)
    @requestor = requestor
    @user      = recipient
    @plan      = plan
    @phase     = plan.phases.first
    if recipient.active?
      FastGettext.with_locale current_locale(recipient) do
        sender = Rails.configuration.branding[:organisation][:do_not_reply_email] || Rails.configuration.branding[:organisation][:email]
        mail(to: recipient.email,
             from: sender,
             subject: _("%{application_name}: Expert feedback has been provided for %{plan_title}") % {application_name: Rails.configuration.branding[:application][:name], plan_title: @plan.title})
      end
    end
  end

  def feedback_confirmation(recipient, plan, requestor)
    user = requestor

    if user.org.present? && recipient.active?
      org = user.org
      plan = plan

      # Use the generic feedback confirmation message unless the Org has specified one
      subject = (org.feedback_email_subject.present? ? org.feedback_email_subject : feedback_confirmation_default_subject)
      message = (org.feedback_email_msg.present? ? org.feedback_email_msg : feedback_confirmation_default_message)

      @body = feedback_constant_to_text(message, user, plan, org)

      FastGettext.with_locale FastGettext.default_locale do
        mail(to: recipient.email,
             subject: feedback_constant_to_text(subject, user, plan, org))
      end
    end
  end

  def plan_visibility(user, plan)
    @user = user
    @plan = plan
    if user.active?
      FastGettext.with_locale current_locale(user) do
        mail(to: @user.email,
             subject: _('DMP Visibility Changed: %{plan_title}') %{ :plan_title => @plan.title })
      end
    end
  end

  # commenter - User who wrote the comment
  # plan      - Plan for which the comment is associated to
  # answer - Answer commented on
  # SEE MODULE
  def new_comment(commenter, plan, answer)
    if commenter.is_a?(User) && plan.is_a?(Plan)
      owner = plan.owner
      if owner.present? && owner.active?
        @commenter = commenter
        @plan = plan
        @answer = answer
        FastGettext.with_locale current_locale(owner) do
          mail(to: owner.email, subject:
            _('%{tool_name}: A new comment was added to %{plan_title}') %{ :tool_name => Rails.configuration.branding[:application][:name], :plan_title => plan.title })
        end
      end
    end
  end

  def admin_privileges(user)
    @user = user
    if user.active?
      FastGettext.with_locale current_locale(@user) do
        mail(to: user.email, subject:
          _('Administrator privileges granted in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
      end
    end
  end

  def anonymization_warning(user)
    @user = user
    @end_date = (@user.last_sign_in_at + 5.years).to_date
    FastGettext.with_locale current_locale(@user) do
      mail(to: @user.email, subject:
        d_('dmpopidor', 'Account expiration in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end

  def anonymization_notice(user)
    @user = user
    FastGettext.with_locale current_locale(@user) do
      mail(to: @user.email, subject:
        d_('dmpopidor', 'Account expired in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end


  private

  def current_locale(user)
    user.get_locale.nil? ? FastGettext.default_locale : user.get_locale
  end
  
end
