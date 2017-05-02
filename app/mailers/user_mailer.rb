class UserMailer < ActionMailer::Base
	default from: Rails.configuration.branding[:organisation][:email]
	
	def sharing_notification(role, user)
    @role = role
    @user = user
    FastGettext.with_locale FastGettext.default_locale do
  		mail(to: @role.user.email, 
           subject: _("You have been given access to a Data Management Plan"))
    end
	end
	
	def permissions_change_notification(role)
		@role = role
		FastGettext.with_locale FastGettext.default_locale do
      mail(to: @role.user.email, 
           subject: _("DMP permissions changed"))
    end
	end
	
	def project_access_removed_notification(user, plan)
		@user = user
		@plan = plan
    FastGettext.with_locale FastGettext.default_locale do
  		mail(to: @user.email, 
           subject: _("DMP access removed"))
    end
	end

  def api_token_granted_notification(user)
      @user = user
      FastGettext.with_locale FastGettext.default_locale do
        mail(to: @user.email, 
             subject: _('API Permission Granted'))
      end
  end
end