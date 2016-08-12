class UserMailer < ActionMailer::Base
	default from: I18n.t('helpers.main_email.from')
	
	def sharing_notification(project_group)
		@project_group = project_group
		mail(to: @project_group.user.email, subject: I18n.t('helpers.main_email.access_given'))
	end
	
	def permissions_change_notification(project_group)
		@project_group = project_group
		mail(to: @project_group.user.email, subject: I18n.t('helpers.main_email.permission_changed'))
	end
	
	def project_access_removed_notification(user, project)
		@user = user
		@project = project
		mail(to: @user.email, subject: I18n.t('helpers.main_email.access_removed'))
	end

  def api_token_granted_notification(user)
      @user = user
      mail(to: @user.email, subject: I18n.t('helper.api_mail_subject'))
  end
end