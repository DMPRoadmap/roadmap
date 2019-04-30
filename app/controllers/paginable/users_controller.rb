# frozen_string_literal: true

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
    paginable_renderise(
      partial: "index",
      scope: scope,
      query_params: { sort_field: 'users.surname', sort_direction: :asc },
      view_all: !current_user.can_super_admin?
    )
  end

end
