# frozen_string_literal: true

# Helper methods for Global notifications and Flash messages
module NotificationsHelper
  # FA html class depending on Notification level
  #
  # Returns String
  def fa_classes(notification)
    case notification.level
    when 'warning'
      'fa-circle-exclamation'
    when 'danger'
      'fa-circle-xmark'
    else
      'fa-circle-info'
    end
  end
end
