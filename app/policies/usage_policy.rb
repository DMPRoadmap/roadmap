# frozen_string_literal: true

# Disabling this rubocop check because this is the recommended approach to having
# a policy that is not associated with a model (per the pundit README)
# rubocop:disable Style/StructInheritance
class UsagePolicy < Struct.new(:user, :usage)
  attr_reader :user

  def initialize(user, usage)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    super
    @user = user
  end

  def index?
    @user.can_org_admin?
  end

  def plans_by_template?
    @user.can_org_admin?
  end

  def global_statistics?
    @user.can_super_admin?
  end

  def org_statistics?
    @user.can_org_admin?
  end

  def all_plans_by_template?
    @user.can_org_admin?
  end

  def yearly_users?
    @user.can_org_admin?
  end

  def yearly_plans?
    @user.can_org_admin?
  end

  def filter?
    @user.can_org_admin?
  end
end
# rubocop:enable Style/StructInheritance
