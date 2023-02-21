# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the notifications table
  class NotificationsController < ApplicationController
    include Paginable

    # /paginable/notifications/index/:page
    def index
      authorize(Notification)
      paginable_renderise(partial: 'index', scope: Notification.all, format: :json)
    end
  end
end
