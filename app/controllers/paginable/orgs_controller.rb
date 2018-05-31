module Paginable 
  class OrgsController < ApplicationController
    include Paginable
    
  # ------------------------------------
  # START DMPTool customization
    # /paginable/orgs/public/:page
    def public
      ids = Org.where("#{Org.organisation_condition} OR #{Org.institution_condition}").pluck(:id)
      paginable_renderise(
        partial: 'public',
        scope: Org.participating.where(id: ids),
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
