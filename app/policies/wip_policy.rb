# frozen_string_literal: true

# Base policy for Plan endpoints
class WipPolicy < ApplicationPolicy
  def new?
    @user.can_org_admin?
  end

  def funders?
    @user.can_org_admin?
  end

  def overview?
    @user.can_org_admin?
  end
end
