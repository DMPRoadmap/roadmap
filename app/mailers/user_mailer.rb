class UserMailer < ActionMailer::Base
  include MailerHelper

  default from: Rails.configuration.branding[:organisation][:email]
  
  def welcome_notification(user)
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email, 
           subject: _('Welcome to %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end
  
  def sharing_notification(role, user)
    @role = role
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: _('A Data Management Plan in %{tool_name} has been shared with you') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end
  
  def permissions_change_notification(role, user)
    @role = role
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: _('Changed permissions on a Data Management Plan in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
    end
  end
  
  # TODO evaluate if it is needed since https://docs.google.com/document/d/1Zt3QfPZ2q6yMOCVFOevXviwRX-XbZeGSxAAvbRa9w-M/edit does not mention it
  def project_access_removed_notification(user, plan, current_user)
    @user = user
    @plan = plan
    @current_user = current_user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email, 
           subject: "#{_('Permissions removed on a DMP in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] }}")
    end
  end

  def api_token_granted_notification(user)
      @user = user
      FastGettext.with_locale FastGettext.default_locale do
        mail(to: @user.email, 
             subject: _('API rights in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
      end
  end
  
  def feedback_notification(recipient, plan, requestor)
    @user = requestor
    
    if @user.org.present?
      @org = @user.org
      @plan = plan
      @recipient = recipient
      
      FastGettext.with_locale FastGettext.default_locale do
        mail(to: recipient.email, 
             subject: _("%{application_name}: %{user_name} requested feedback on a plan") % {application_name: Rails.configuration.branding[:application][:name], user_name: @user.name(false)})
      end
    end
  end
  
  def feedback_confirmation(recipient, plan, requestor)
    user = requestor

    if user.org.present?
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
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email,
        subject: _('DMP Visibility Changed: %{plan_title}') %{ :plan_title => @plan.title })
    end
  end
  
  # @param commenter - User who wrote the comment
  # @param plan - Plan for which the comment is associated to
  def new_comment(commenter, plan)
    if commenter.is_a?(User) && plan.is_a?(Plan)
      if plan.owner.present?
        @commenter = commenter
        @plan = plan
        FastGettext.with_locale FastGettext.default_locale do
          mail(to: plan.owner.email, subject:
            _('%{tool_name}: A new comment was added to %{plan_title}') %{ :tool_name => Rails.configuration.branding[:application][:name], :plan_title => plan.title })
        end
      end
    end
  end
end
