module Paginable
  class StaticPagesController < ApplicationController
    include Paginable
  
    # /paginable/static_pages/index/:page
    def index
      authorize(StaticPage)
      paginable_renderise(partial: 'index', scope: StaticPage.all)
    end
  end
end