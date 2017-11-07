class UserMailer < ActionMailer::Base
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
           subject: "#{_('Permissions removed on a DMP in')} #{Rails.configuration.branding[:application][:name]}")
    end
  end

  def api_token_granted_notification(user)
      @user = user
      FastGettext.with_locale FastGettext.default_locale do
        mail(to: @user.email, 
             subject: _('API rights in %{tool_name}') %{ :tool_name => Rails.configuration.branding[:application][:name] })
      end
  end
  
  def feedback_notification(user, plan)
    @user = user

    if user.org.present?
      @org = org
      @plan = plan
      
      # Use the generic feedback message unless the Org has specified one
      subject = org.feedback_email_subject ||= EMAIL_FEEDBACK_REQUESTED_CONFIRMATION_SUBJECT
      
      # Send an email to all of the org admins as well as the Org's administrator email
      emails = user.org.users.select{ |usr| usr.can_org_admin? && usr != user }
      emails << user.org.contact_email if user.org.contact_email.present?
      
      emails.each do |email|
        @email = email
        FastGettext.with_locale FastGettext.default_locale do
          mail(to: email, subject: subject)
        end
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
end
