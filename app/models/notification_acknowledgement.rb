class NotificationAcknowledgement < ActiveRecord::Base
  # Does the notification acknowledgement table
  # contains a given user and notification association ?
  # @param user concerned User
  # @param notification concerned Notification
  # @return [Boolean] is the User-Notification association present ?
  def self.has?(user, notification)
    return false if user.nil? # In case user is undefined (login page)
    !where(
      'user_id = ? and notification_id = ?', user.id, notification.id
    ).first.nil?
  end
end
