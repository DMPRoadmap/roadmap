class GuidancePolicy < ApplicationPolicy
  attr_reader :user, :guidance

  def initialize(user, guidance)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @guidance = guidance
  end

  def admin_show?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.organisation_id)
  end

  def admin_edit?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.organisation_id)
  end

  def admin_update?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.organisation_id)
  end

  def admin_index?
    user.can_modify_guidance?
  end

  def admin_new?
    user.can_modify_guidance?
  end

  def admin_create?
    user.can_modify_guidance?
  end

  def admin_destroy?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.organisation_id)
  end

  class Scope < Scope
    def resolve
      scope = Guidance.by_organisation(user.organisation_id)
    end
  end
end