# frozen_string_literal: true

module Dmptool

  class Paginable::OrgsController < ApplicationController

    include Paginable

    # /paginable/orgs/public/:page
    def public
      ids = Org.where("#{Org.organisation_condition} OR #{Org.institution_condition}").pluck(:id)
      paginable_renderise(
        partial: 'public',
        scope: Org.participating.where(id: ids),
        query_params: { sort_field: 'orgs.name', sort_direction: :asc }
      )
    end

    # /paginable/guidances/index/:page
    def index
      authorize(Org)
      paginable_renderise(
        partial: "index",
        scope: Org.includes(:templates, :users),
        query_params: { sort_field: "orgs.name", sort_direction: :asc })
    end

  end

end
