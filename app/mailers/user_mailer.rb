class UserMailer < ActionMailer::Base
  default from: Rails.configuration.branding[:organisation][:email]
  
  def welcome_notification(user)
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @user.email, 
           subject: "#{_('Welcome to')} #{Rails.configuration.branding[:application][:name]}")
    end
  end
  
  def sharing_notification(role, user)
    @role = role
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: "#{_('A Data Management Plan in ')} #{Rails.configuration.branding[:application][:name]} #{_(' has been shared with you')}")
    end
  end
  
  def permissions_change_notification(role, current_user)
    @role = role
                @current_user = current_user
    FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: "#{_('Changed permissions on a DMP in')} #{Rails.configuration.branding[:application][:name]}")
    end
  end
  
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
             subject: "#{_('API rights in')} #{Rails.configuration.branding[:application][:name]}")
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
end
