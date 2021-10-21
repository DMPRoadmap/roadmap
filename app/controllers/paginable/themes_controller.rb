# frozen_string_literal: true

class Paginable::ThemesController < ApplicationController

  include Paginable

  # /paginable/themes/index/:page
  def index
    authorize(Theme)
    paginable_renderise(partial: "index", scope: Theme.all, format: :json)
  end

end
