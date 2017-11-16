class PlanPolicy < ApplicationPolicy
  attr_reader :user

  def initialize(user)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user 
    raise Pundit::NotAuthorizedError, _("are not authorized to view that plan") unless user.can_org_admin?
    @user = user
  end

end
