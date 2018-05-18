class GuidancePolicy < ApplicationPolicy
  attr_reader :user, :guidance

  def initialize(user, guidance)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @guidance = guidance
  end

  def admin_show?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.org_id)
  end

  def admin_edit?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.org_id)
  end

  def admin_update?
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.org_id)
  end

  def index?
    admin_index?
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
    user.can_modify_guidance? && guidance.in_group_belonging_to?(user.org_id)
  end

  def admin_publish?
    user.can_modify_guidance?
  end

  def admin_unpublish?
    user.can_modify_guidance?
  end

  def update_phases?
    user.can_modify_guidance?
  end

  def update_versions?
    user.can_modify_guidance?
  end

  def update_sections?
    user.can_modify_guidance?
  end

  def update_questions?
    user.can_modify_guidance?
  end
end