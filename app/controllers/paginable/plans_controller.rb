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
      query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
      format: :json
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
      query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
      format: :json
    )
  end

  # GET /paginable/plans/publicly_visible/:page
  def publicly_visible
    paginable_renderise(
      partial: "publicly_visible",
      scope: Plan.publicly_visible.includes(:template),
      query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
      format: :json
    )
  end

  # GET /paginable/plans/org_admin/:page
  def org_admin
    raise Pundit::NotAuthorizedError unless current_user.present? && current_user.can_org_admin?

    # check if current user if super_admin
    @super_admin = current_user.can_super_admin?
    @clicked_through = params[:click_through].present?
    plans = @super_admin ? Plan.all : current_user.org.plans
    plans = plans.joins(:template, roles: [user: :org]).where(Role.creator_condition)

    paginable_renderise(
      partial: "org_admin",
      scope: plans,
      view_all: !current_user.can_super_admin?,
      query_params: { sort_field: "plans.updated_at", sort_direction: :desc },
      format: :json
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
      query_params: { sort_field: "plans.updated_at", sort_direction: :desc }
    )
  end

end
