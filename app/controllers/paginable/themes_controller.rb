# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the themes table
  class ThemesController < ApplicationController
    include Paginable

    # /paginable/themes/index/:page
    def index
      authorize(Theme)
      paginable_renderise(partial: 'index', scope: Theme.all, format: :json)
    end
  end
end
