class UserMailerPreview < ActionMailer::Preview
  def initialize
    @user = User.find_by(email: 'super_admin@example.com')
  end
  def welcome_notification
    UserMailer.welcome_notification(@user)
  end
  def sharing_notification
    UserMailer.sharing_notification(Role.find_by(user_id: @user.id), user)
  end
  def permissions_change_notification
    UserMailer.permissions_change_notification(Role.find_by(user_id: @user.id), user)
  end
  # relative_url at /rails/mailers/user_mailer/plan_access_removed
  def plan_access_removed
    UserMailer.plan_access_removed(@user, @user.plans.first, @user)
  end
  def api_token_granted_notification
    UserMailer.api_token_granted_notification(@user)
  end
  def plan_visibility
    UserMailer.plan_visibility(@user, @user.plans.first)
  end
  def new_comment
    plan = Plan.joins(:roles).where(Role.creator_condition).first
    UserMailer.new_comment(@user, plan)
  end
  # relative_url at /rails/mailers/user_mailer/admin_privileges
  def admin_privileges
    UserMailer.admin_privileges(@user)
  end
end