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
	
	def permissions_change_notification(role)
		@role = role
		FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: "#{_('Changed permissions on a DMP in')} #{Rails.configuration.branding[:application][:name]}")
    end
	end
	
	def project_access_removed_notification(user, plan)
		@user = user
		@plan = plan
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
end