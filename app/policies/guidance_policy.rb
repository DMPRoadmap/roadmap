# frozen_string_literal: true

# Security rules for guidance
# Note the method names here correspond with controller actions
class GuidancePolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Guidance

  def admin_show?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def admin_edit?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def admin_update?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def index?
    admin_index?
  end

  def admin_index?
    @user.can_modify_guidance?
  end

  def admin_new?
    @user.can_modify_guidance?
  end

  def admin_create?
    @user.can_modify_guidance?
  end

  def admin_destroy?
    @user.can_modify_guidance? && @record.in_group_belonging_to?(@user.org_id)
  end

  def admin_publish?
    @user.can_modify_guidance?
  end

  def admin_unpublish?
    @user.can_modify_guidance?
  end
end
