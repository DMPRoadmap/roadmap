class UserMailerPreview < ActionMailer::Preview
  def initialize
    @org = Org.first
    @recipient = User.new(email: "recipient@example.org", firstname: "Test", surname: "Recipient",
                              password: "password123", password_confirmation: "password123", org: @org, 
                              accept_terms: true, confirmed_at: Time.zone.now)
    @requestor = User.new(email: "requestor@example.org", firstname: "Test", surname: "Requestor",
                              password: "password123", password_confirmation: "password123", org: @org, 
                              accept_terms: true, confirmed_at: Time.zone.now)
    @template = Template.new(title: 'Test template', description: 'My test template', org: @org, 
                                 archived: false, family_id: "9999999")
    @plan = Plan.new(template: @template, title: 'Test Plan', grant_number: 'Grant-123',
                     principal_investigator: 'Researcher', principal_investigator_identifier: 'researcher-1234',
                     description: "this is my plan's informative description",
                     identifier: '1234567890', data_contact: 'researcher@example.org', visibility: :privately_visible)
    @role = Role.new(user: @requestor, plan: @plan, access: 14)
  end
  def welcome_notification
    UserMailer.welcome_notification(@requestor)
  end
  def sharing_notification
    UserMailer.sharing_notification(@role, @recipient)
  end
  def permissions_change_notification
    UserMailer.permissions_change_notification(@role, @recipient)
  end
  # relative_url at /rails/mailers/user_mailer/plan_access_removed
  def plan_access_removed
    UserMailer.plan_access_removed(@requestor, @plan, @recipient)
  end
  def api_token_granted_notification
    UserMailer.api_token_granted_notification(@requestor)
  end
  def feedback_notification
    UserMailer.feedback_notification(@requestor, @plan, @recipient)
  end
  def feedback_complete
    UserMailer.feedback_complete(@requestor, @plan, @recipient)
  end
  def feedback_confirmation
    UserMailer.feedback_confirmation(@requestor, @plan, @recipient)
  end
  def plan_visibility
    UserMailer.plan_visibility(@requestor, @plan)
  end
  def new_comment
    plan = Plan.joins(:roles).where(Role.creator_condition).first
    UserMailer.new_comment(@requestor, plan)
  end
  # relative_url at /rails/mailers/user_mailer/admin_privileges
  def admin_privileges
    UserMailer.admin_privileges(@requestor)
  end
end