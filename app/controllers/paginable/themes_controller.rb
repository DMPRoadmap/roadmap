module Paginable 
  class ThemesController < ApplicationController
    include Paginable
    # /paginable/themes/index/:page
    def index
      raise Pundit::NotAuthorizedError unless SuperAdmin::ThemePolicy.new(current_user).index?
      themes = params[:page] == 'ALL' ?
        Theme.all :
        Theme.page(params[:page])
      paginable_renderise(partial: 'index', scope: themes)
    end
  end
end