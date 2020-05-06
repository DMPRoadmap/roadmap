# frozen_string_literal: true

class Paginable::UsersController < ApplicationController

  include Paginable

  # /paginable/users/index/:page
  def index
    authorize User
    @clicked_through = params[:click_through].present?

    # variable containing the check box value
    filter = params[:filter_admin] == "1"

    if current_user.can_super_admin?
      scope = User.includes(:roles)
    else
      scope = current_user.org.users.includes(:roles)
    end

    if filter
      scope = scope.joins(:perms)
    end


    paginable_renderise(
      partial: "index",
      scope: scope,
      query_params: { sort_field: 'users.surname', sort_direction: :asc , filter_admin: filter },
      view_all: !current_user.can_super_admin?
    )
  end

end
