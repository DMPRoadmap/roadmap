class UserMailerPreview < ActionMailer::Preview
  def welcome_notification
    UserMailer.welcome_notification(User.find_by(email: 'super_admin@example.com'))
  end
  def sharing_notification
    user = User.find_by(email: 'super_admin@example.com')
    UserMailer.sharing_notification(Role.find_by(user_id: user.id), user)
  end
  def permissions_change_notification
    user = User.find_by(email: 'super_admin@example.com')
    UserMailer.permissions_change_notification(Role.find_by(user_id: user.id), user)
  end
  def api_token_granted_notification
    user = User.find_by(email: 'super_admin@example.com')
    UserMailer.api_token_granted_notification(user)
  end
end