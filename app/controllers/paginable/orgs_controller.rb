class Paginable::OrgsController < ApplicationController
  include Paginable
  # /paginable/guidances/index/:page
  def index
    authorize(Org)
    paginable_renderise(
      partial: 'index',
      scope: Org.includes(:templates, :users),
      query_params: { sort_field: 'orgs.name', sort_direction: :asc })
  end
end
