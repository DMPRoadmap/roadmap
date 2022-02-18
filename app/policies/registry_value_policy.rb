# frozen_string_literal: true

# Security rules for registry value
class RegistryValuePolicy < ApplicationPolicy
  def index?
    @user.can_super_admin?
  end
end
