# frozen_string_literal: true

class Paginable::UsersController < ApplicationController

  include Paginable

  # /paginable/users/index/:page
  def index
    authorize User
    if current_user.can_super_admin?
      scope = User.joins(:org, :perms, :plans)
                         .includes(:org, :perms)
                         .group("users.id")
                         .select("users.*,
                                  count(plans.id) as plan_count")
    else
      scope = User.joins(:org, :perms, :plans)
                         .includes(:org, :perms)
                         .where(users: { org_id: current_user.org.id })
                         .group("users.id")
                         .select("users.*,
                                  count(plans.id) as plan_count")
    end
    paginable_renderise(
      partial: "index",
      scope: scope,
      query_params: { sort_field: 'users.surname', sort_direction: :asc },
      view_all: !current_user.can_super_admin?
    )
  end

end
