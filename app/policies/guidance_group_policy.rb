class GuidanceGroupPolicy < ApplicationPolicy
  attr_reader :user, :guidance_group

  def initialize(user, guidance_group)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @guidance_group = guidance_group
  end

  def admin_show?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_edit?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_update?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_update_publish?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_new?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_create?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  def admin_destroy?
    user.can_modify_guidance? && (guidance_group.organisation_id == user.organisation_id)
  end

  class Scope < Scope
    def resolve
      scope.where(organisation_id: user.organisation_id)
    end
  end

end