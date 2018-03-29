class Notification < ActiveRecord::Base
  enum level: %i[info warning danger]

  belongs_to :notification_type
  alias type notification_type

  validates :notification_type_id, :title, :level, :starts_at, :expires_at, :body, presence: true
  validate :valid_dates

  # Return wether or not the notification is active (started and not expired)
  # @return [Boolean] active or not
  def active?
    return false if User.current.nil? && dismissable?
    starts_at <= Time.now && Time.now < expires_at
  end

  # Get all active Notifications
  # @return [Notification::ActiveRecord_Relation] a collection of all active Notifications
  def self.all_active
    active = where('starts_at <= :now and :now < expires_at', now: Time.now)
    return active.where('dismissable = false') if User.current.nil?
    active
  end

  # Acknowledge the Notification for the User (current user is the default)
  # @param user User for which to acknowledge the Notification
  # @return [Boolean] is the Notification successfully acknowledged ?
  def acknowledge(user = User.current)
    return false if !dismissable? || user.nil?
    true if NotificationAcknowledgement.create(user_id: user.id, notification_id: id)
  end

  # Has the Notification been acknowledged by the given user ?
  # If no user is given, currently logged in user (if any) is the default
  # @return [Boolean] is the Notification acknowledged ?
  def acknowledged?(user = User.current)
    NotificationAcknowledgement.has?(user, self)
  end

  # Validate Notification dates
  def valid_dates
    return false if starts_at.blank? || expires_at.blank?
    errors.add(:starts_at, _('Should be today or later')) if starts_at < Date.today
    errors.add(:expires_at, _('Should be tomorrow or later')) if expires_at < Date.tomorrow
    if starts_at > expires_at
      errors.add(:starts_at, _('Should be before expiration date'))
      errors.add(:expires_at, _('Should be after start date'))
    end
  end
end
