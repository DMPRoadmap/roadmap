class Paginable::UsersController < ApplicationController
  include Paginable
  # /paginable/users/index/:page
  def index
    authorize User
    if current_user.can_super_admin?
      scope = User.includes(:roles)
    else
      scope = current_user.org.users.includes(:roles)
    end
    paginable_renderise(partial: 'index', scope: scope, view_all: !current_user.can_super_admin?)
  end
end