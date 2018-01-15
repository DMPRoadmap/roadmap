module Paginable 
  class ThemesController < ApplicationController
    include Paginable
    # /paginable/themes/index/:page
    def index
      authorize(Theme)
      paginable_renderise(partial: 'index', scope: Theme.all)
    end
  end
end