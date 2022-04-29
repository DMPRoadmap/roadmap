# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the static pages table
  class StaticPagesController < ApplicationController
    include Paginable

    # /paginable/static_pages/index/:page
    def index
      authorize(StaticPage)
      paginable_renderise(
        partial: 'index',
        scope: StaticPage.all,
        query_params: { sort_field: 'static_pages.name', sort_direction: :asc },
        format: :json
      )
    end
  end
end
