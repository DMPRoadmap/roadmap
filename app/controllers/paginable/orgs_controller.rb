class Paginable::OrgsController < ApplicationController
  include Paginable
  # /paginable/guidances/index/:page
  def index
    authorize(Org)
    paginable_renderise(
      partial: 'index',
      scope: Org.includes(:templates, :users).joins(:templates, :users)
    )
  end
end
