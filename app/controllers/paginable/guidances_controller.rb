# frozen_string_literal: true

class Paginable::GuidancesController < ApplicationController

  include Paginable

  # /paginable/guidances/index/:page
  def index
    authorize(Guidance)
    paginable_renderise(
      partial: "index",
      scope: Guidance.by_org(current_user.org)
                     .includes(:guidance_group, :themes),
      query_params: { sort_field: "guidances.text", sort_direction: :asc },
      format: :json
    )
  end

end
