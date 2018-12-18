# frozen_string_literal: true

class Paginable::GuidanceGroupsController < ApplicationController

  include Paginable

  # /paginable/guidance_groups/index/:page
  def index
    authorize(Guidance)
    paginable_renderise(partial: "index",
      scope: GuidanceGroup.by_org(current_user.org),
      query_params: { sort_field: "guidance_groups.name", sort_direction: :asc }
    )
  end

end
