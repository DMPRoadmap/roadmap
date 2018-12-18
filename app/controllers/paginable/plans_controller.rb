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
      scope: Plan.publicly_visible,
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

  # GET /paginable/plans/org_admin/:page
  def org_admin
    unless current_user.present? && current_user.can_org_admin?
      raise Pundit::NotAuthorizedError
    end
    paginable_renderise(
      partial: "org_admin",
      scope: current_user.org.plans,
      query_params: { sort_field: 'plans.updated_at', sort_direction: :desc }
    )
  end

end
