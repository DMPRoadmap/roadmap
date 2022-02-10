# frozen_string_literal: true

class Paginable::NotificationsController < ApplicationController

  include Paginable

  # /paginable/notifications/index/:page
  def index
    authorize(Notification)
    paginable_renderise(partial: "index", scope: Notification.all, format: :json)
  end

end
