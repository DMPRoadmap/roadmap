require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  setup do
    @super_admin = User.find_by(email: 'super_admin@example.com')

    @notification = Notification.create!(
      notification_type: Notification.notification_types[:global], 
      title: 'notification_1', 
      level: Notification.levels[:info],
      body: 'notification 1', 
      dismissable: true, 
      starts_at: Time.now,
      expires_at: Time.now + 1.days)
  end

  # Validity
  test 'validations valid' do
    1.upto(10) { |i| assert(@notification.valid?) }
  end

  # Date validation
  test 'validations inconsistent dates' do
    @notification.expires_at = Date.today - 1.days
    assert_not(@notification.valid?)
  end

  # Missing parameters
  test 'validations missing params' do
    @notification.dismissable = nil
    assert(@notification.valid?)
    @notification.dismissable = false
    @notification.notification_type = nil
    assert_not(@notification.valid?)
    @notification.notification_type = Notification.notification_types[:global]
    @notification.title = nil
    assert_not(@notification.valid?)
    @notification.title = "Testing"
    @notification.body = nil
    assert_not(@notification.valid?)
    @notification.body = "Testing"
    @notification.level = nil
    assert_not(@notification.valid?)
    @notification.level = Notification.levels[:info]
    @notification.starts_at = nil
    assert_not(@notification.valid?)
    @notification.starts_at = Time.now
    @notification.expires_at = nil
    assert_not(@notification.valid?)
  end
end
