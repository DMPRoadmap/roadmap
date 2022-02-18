# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the contributors table
  class ContributorsController < ApplicationController
    after_action :verify_authorized
    # --------------------------------
    # Start DMP OPIDoR Customization
    # SEE app/controllers/dmpopidor/paginable/contributors_controller.rb
    # --------------------------------
    prepend Dmpopidor::Paginable::ContributorsController
    # --------------------------------
    # End DMP OPIDoR Customization
    # --------------------------------
    respond_to :html

    include Paginable

    # --------------------------------
    # Start DMP OPIDoR Customization
    # SEE app/controllers/dmpopidor/paginable/contributors_controller.rb
    # CHANGES : Contributors tab display DMP OPIDoR contributors (madmp_fragments)
    # --------------------------------
    # GET /paginable/plans/:plan_id/contributors
    # GET /paginable/plans/:plan_id/contributors/index/:page
    def index
      @plan = Plan.find_by(id: params[:plan_id])
      authorize @plan, :show?
      paginable_renderise(
        partial: 'index',
        scope: Contributor.where(plan_id: @plan.id),
        query_params: { sort_field: 'contributors.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
