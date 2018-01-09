class OrgPolicy < ApplicationPolicy
  attr_reader :user, :org

  def initialize(user, org)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @org = org
  end

  def admin_show?
    user.can_modify_org_details? && (user.org_id == org.id)
  end

  def admin_edit?
    user.can_modify_org_details? && (user.org_id == org.id)
  end

  def admin_update?
    user.can_modify_org_details? && (user.org_id == org.id)
  end

  def parent?
    true
  end

  def children?
    true
  end

  def templates?
    true
  end
end