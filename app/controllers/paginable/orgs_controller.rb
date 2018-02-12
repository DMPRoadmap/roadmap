module Paginable 
  class OrgsController < ApplicationController
    include Paginable
    
    # /paginable/orgs/public/:page
    def public
      paginable_renderise(
        partial: 'public',
        scope: Org.includes(:identifier_schemes).all
      )
    end
    
    # /paginable/orgs/index/:page
    def index
      authorize(Org)
      paginable_renderise(
        partial: 'index',
        scope: Org.includes(:templates, :users).all
      )
    end
  end
end
