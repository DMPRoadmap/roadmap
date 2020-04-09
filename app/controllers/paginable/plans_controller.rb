# frozen_string_literal: true

class Paginable::PlansController < ApplicationController

  include Paginable

  # /paginable/plans/privately_visible/:page
  def privately_visible
    unless Paginable::PlanPolicy.new(current_user).privately_visible?
      raise Pundit::NotAuthorizedError
    end
    paginable_renderise(
      partial: "privately_visible",
      scope: Plan.active(current_user),
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

  # GET /paginable/plans/organisationally_or_publicly_visible/:page
  def organisationally_or_publicly_visible
    unless Paginable::PlanPolicy.new(current_user).organisationally_or_publicly_visible?
      raise Pundit::NotAuthorizedError
    end
    paginable_renderise(
      partial: "organisationally_or_publicly_visible",
      scope: Plan.organisationally_or_publicly_visible(current_user),
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

  # GET /paginable/plans/publicly_visible/:page
  def publicly_visible
    paginable_renderise(
      partial: "publicly_visible",
      scope: Plan.publicly_visible.includes(:template),
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

  # GET /paginable/plans/org_admin/:page
  def org_admin
    unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end
    #check if current user if super_admin
    @super_admin = current_user.can_super_admin?
    @filter = params[:month]

    if @super_admin && !@filter.present?
      plans = Plan.all
    elsif @filter.present?
      # Convert an incoming month from the usage dashboard into a date range query
      # the month is appended to the query string when a user clicks on a bar in
      # the plans created chart
      start_date = Date.parse("#{@filter}-01")

      # Also ignore tests here since the usage dashboard ignores them and showing
      # them here may be confusing to the user
      plans = current_user.org.plans
                          .where.not(visibility: Plan.visibilities[:is_test])
                          .where("plans.created_at BETWEEN ? AND ?",
                                 start_date.to_s, start_date.end_of_month.to_s)
    else
      plans = current_user.org.plans
    end

    paginable_renderise(
      partial: "org_admin",
      scope: plans,
      view_all: !current_user.can_super_admin?,
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

  # GET /paginable/plans/org_admin/:page
  def org_admin_other_user
    @user = User.find(params[:id])
    authorize @user
    unless current_user.present? && current_user.can_org_admin? && @user.present?
      raise Pundit::NotAuthorizedError
    end
    paginable_renderise(
      partial: "org_admin_other_user",
      scope: Plan.active(@user),
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

end
