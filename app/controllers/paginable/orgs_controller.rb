module Paginable 
  class OrgsController < ApplicationController
    include Paginable
    
  # ------------------------------------
  # START DMPTool customization
    # /paginable/orgs/public/:page
    def public
      funders = Org.funder.collect(&:id)
      paginable_renderise(
        partial: 'public',
        scope: Org.participating.where.not(id: funders),
        query_params: { sort_field: 'orgs.name', sort_direction: :asc }
      )
    end
  # END DMPTool customization
  # ------------------------------------
  
    # /paginable/orgs/index/:page
    def index
      authorize(Org)
      paginable_renderise(
        partial: 'index',
        scope: Org.includes(:templates, :users),
        query_params: { sort_field: 'orgs.name', sort_direction: :asc }
      )
    end
  end
end
