module Paginable 
  class ThemesController < ApplicationController
    include Paginable
    # /paginable/themes/index/:page
    def index
      authorize(Theme)
      themes = params[:page] == 'ALL' ?
        Theme.updated_at_desc :
        Theme.updated_at_desc.page(params[:page])
      paginable_renderise(partial: 'index', scope: themes)
    end
  end
end