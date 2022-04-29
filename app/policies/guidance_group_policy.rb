# frozen_string_literal: true

# Security rules for guidance group editing
# Note the method names here correspond with controller actions
class GuidanceGroupPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of GuidanceGroup

  def admin_show?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def admin_edit?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def admin_update?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def admin_update_publish?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def admin_update_unpublish?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  def admin_new?
    @user.can_modify_guidance?
  end

  def admin_create?
    @user.can_modify_guidance?
  end

  def admin_destroy?
    @user.can_modify_guidance? && (@record.org_id == @user.org_id)
  end

  # Returns the guidance groups for the specified org
  class Scope < Scope
    def resolve
      scope.where(org_id: @user.org_id)
    end
  end
end
