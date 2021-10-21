# frozen_string_literal: true

class Paginable::OrgsController < ApplicationController

  include Paginable

  # /paginable/guidances/index/:page
  def index
    authorize(Org)
    paginable_renderise(
      partial: "index",
      scope: Org.with_template_and_user_counts,
      query_params: { sort_field: "orgs.name", sort_direction: :asc },
      format: :json
    )
  end

end
