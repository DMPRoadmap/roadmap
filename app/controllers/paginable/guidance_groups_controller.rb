module Paginable 
  class GuidanceGroupsController < ApplicationController
    include Paginable
    # /paginable/guidance_groups/index/:page
    def index
      authorize(Guidance)
      paginable_renderise(partial: 'index',
        scope: GuidanceGroup.by_org(current_user.org))
    end
  end
end