# frozen_string_literal: true

class Paginable::OrgsController < ApplicationController

  include Paginable

  # /paginable/guidances/index/:page
  def index
    authorize(Org)
    paginable_renderise(
      partial: "index",
      scope: Org.joins(:templates, :users)
                .select("orgs.*,
                         count(distinct templates.family_id) as template_count,
                         count(users.id) as user_count"),
      query_params: { sort_field: "orgs.name", sort_direction: :asc }
    )
  end

end
