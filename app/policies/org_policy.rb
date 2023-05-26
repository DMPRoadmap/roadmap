# frozen_string_literal: true

# Security rules for orgs
# Note the method names here correspond with controller actions
class OrgPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Org

  def list?
    @user.present?
  end

  def admin_show?
    @user.can_modify_org_details? && (@user.org_id == @record.id)
  end

  def admin_edit?
    @user.can_modify_org_details? && (@user.org_id == @record.id || @user.can_super_admin?)
  end

  def admin_update?
    @user.can_modify_org_details? && (@user.org_id == @record.id || @user.can_super_admin?)
  end

  def index?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    @user.can_super_admin?
  end

  def destroy?
    @user.can_super_admin?
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

  def merge_analyze?
    @user.can_super_admin?
  end

  def merge_commit?
    @user.can_super_admin?
  end
end
