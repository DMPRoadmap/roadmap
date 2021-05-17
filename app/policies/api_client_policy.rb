# frozen_string_literal: true

class ApiClientPolicy < ApplicationPolicy

  def initialize(user, api_client)
    raise Pundit::NotAuthorizedError, _("must be logged in") unless user

    @user = user
    @api_client = api_client
  end

  def index?
    @user.can_super_admin?
  end

  def new?
    @user.can_super_admin?
  end

  def create?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @api_client.user_id
  end

  def edit?
    @user.can_super_admin?
  end

  def update?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @api_client.user_id
  end

  def destroy?
    @user.can_super_admin?
  end

  def refresh_credentials?
    # Super admin or the user can do this for themselves
    @user.can_super_admin? || @user.id == @api_client.user_id
  end

  def email_credentials?
    @user.can_super_admin?
  end

end
