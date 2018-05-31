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
    user.can_modify_org_details? && (user.org_id == org.id || user.can_super_admin?)
  end

  def admin_update?
    user.can_modify_org_details? && (user.org_id == org.id || user.can_super_admin?)
  end

  def index?
    user.can_super_admin?
  end
  def new?
    user.can_super_admin?
  end
  def create?
    user.can_super_admin?
  end
  def destroy?
    user.can_super_admin?
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
  
# START DMPTool customization
# ---------------------------------------------------------
  def public?
    true
  end
# ---------------------------------------------------------
# END DMPTool customization

end