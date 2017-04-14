class UserMailer < ActionMailer::Base
	default from: Rails.configuration.branding[:organisation][:email]
	
	def sharing_notification(role)
    @role = role
		mail(to: @role.user.email, 
         subject: _("You have been given access to a Data Management Plan"))
	end
	
	def permissions_change_notification(role)
		@role = role
		mail(to: @role.user.email, 
         subject: _("DMP permissions changed"))
	end
	
	def project_access_removed_notification(user, plan)
		@user = user
		@plan = plan
		mail(to: @user.email, 
         subject: _("DMP access removed"))
	end

  def api_token_granted_notification(user)
      @user = user
      mail(to: @user.email, 
           subject: _('API Permission Granted'))
  end
end