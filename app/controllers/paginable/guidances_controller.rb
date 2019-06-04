# frozen_string_literal: true

class Paginable::GuidancesController < ApplicationController

  include Paginable

  # /paginable/guidances/index/:page
  def index
    authorize(Guidance)
    paginable_renderise(
      partial: "index",
      scope: org.admin,
      query_params: { sort_field: "guidances.text", sort_direction: :asc }
    )
  end

end
