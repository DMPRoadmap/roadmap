class GuidanceGroupPolicy < ApplicationPolicy
  attr_reader :user, :guidance_group

  def initialize(user, guidance_group)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @guidance_group = guidance_group
  end

  def admin_show?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  def admin_edit?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  def admin_update?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  def admin_update_publish?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  def admin_update_unpublish?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  def admin_new?
    user.can_modify_guidance?
  end

  def admin_create?
    user.can_modify_guidance?
  end

  def admin_destroy?
    user.can_modify_guidance? && (guidance_group.org_id == user.org_id)
  end

  class Scope < Scope
    def resolve
      scope.where(org_id: user.org_id)
    end
  end

end