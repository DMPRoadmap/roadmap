# frozen_string_literal: true

class Paginable::UsersController < ApplicationController

  include Paginable

  # /paginable/users/index/:page
  def index
    authorize User
    @filter = params[:month]

    if current_user.can_super_admin? && !@filter.present?
      scope = User.includes(:roles)
    elsif @filter.present?
      # Convert an incoming month from the usage dashboard into a date range query
      # the month is appended to the query string when a user clicks on a bar in
      # the users joined chart
      start_date = Date.parse("#{@filter}-01")
      scope = current_user.org.users.includes(:roles)
                          .where("users.created_at BETWEEN ? AND ?",
                                 start_date.to_s, start_date.end_of_month.to_s)
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
