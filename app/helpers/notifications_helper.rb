module NotificationsHelper
  # Return FA html class depending on Notification level
  # @return [String] Font Awesome HTML class
  def fa_classes(notification)
    case notification.level
    when 'warning'
      'fa-exclamation-circle'
    when 'danger'
      'fa-times-circle'
    else
      'fa-info-circle'
    end
  end
end
