module Paginable
  class NotificationsController < ApplicationController
    include Paginable
    # /paginable/notifications/index/:page
    def index
      authorize(Notification)
      paginable_renderise(partial: 'index', scope: Notification.all)
    end
  end
end
