module Paginable 
  class ThemesController < ApplicationController
    include Paginable
    # /paginable/themes/index/:page
    def index
      authorize(Theme)
      themes = Theme.updated_at_desc
      if params[:search].present?
        themes = themes.search(params[:search])
        themes = params[:page] == 'ALL' ? themes.page(1) : themes.page(params[:page])
      else
        themes = params[:page] == 'ALL' ? themes : themes.page(params[:page])
      end
      paginable_renderise(partial: 'index', scope: themes)
    end
  end
end