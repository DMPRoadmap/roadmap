module Paginable 
  class GuidancesController < ApplicationController
    include Paginable
    # /paginable/guidances/index/:page
    def index
      authorize(Guidance)
      paginable_renderise(partial: 'index',
        scope: Guidance.by_org(current_user.org).includes(:guidance_group, :themes))
    end
  end
end