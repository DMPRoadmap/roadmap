# frozen_string_literal: true

class RegistryValuePolicy < ApplicationPolicy

  def initialize(user, *args)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user
    @user = user
  end

  def index?
    @user.can_super_admin?
  end

end
