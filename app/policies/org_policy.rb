# frozen_string_literal: true
<<<<<<< HEAD

class OrgPolicy < ApplicationPolicy

  attr_reader :user, :org

  def initialize(user, org)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
    @org = org
  end
=======

# Security rules for orgs
# Note the method names here correspond with controller actions
class OrgPolicy < ApplicationPolicy
  # NOTE: @user is the signed_in_user and @record is an instance of Org
>>>>>>> upstream/master

  def admin_show?
    @user.can_modify_org_details? && (@user.org_id == @record.id)
  end

  def admin_edit?
<<<<<<< HEAD
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
=======
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
>>>>>>> upstream/master
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
<<<<<<< HEAD
    user.can_super_admin?
  end

  def merge_commit?
    user.can_super_admin?
  end

=======
    @user.can_super_admin?
  end

  def merge_commit?
    @user.can_super_admin?
  end
>>>>>>> upstream/master
end
