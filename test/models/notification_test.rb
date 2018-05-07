require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  fixtures :notifications, :users

  # Validity
  test 'validations valid' do
    1.upto(10) { |i| assert(notifications("notification_#{i}").valid?) }
  end

  # Date validation
  test 'validations inconsistent dates' do
    assert_not(notifications(:inconsistent_dates).valid?)
  end

  # Missing parameters
  test 'validations missing params' do
    assert(notifications(:missing_dismissable).valid?)

    notifications(
      :missing_type_id,
      :missing_title,
      :missing_body,
      :missing_level,
      :missing_starts_at,
      :missing_expires_at
    ).each do |n|
      assert_not(n.valid?)
    end
  end

  # Active notification (has started and not expired)
  test 'active notification' do
    n = notifications(:notification_1)

    # Not logged in, dismissable Notification
    User.current = nil
    n.update(dismissable: true)
    assert_not(n.active?)

    # Not logged in, undismissable Notification
    n.update(dismissable: false)
    assert(n.active?)

    # Logged in, undismissable Notification
    User.current = users(:super_admin)
    assert(n.active?)

    # Logged in, dismissable Notification
    n.update(dismissable: true)
    assert(n.active?)
  end

  # Inactive notification (has not started)
  test 'inactive notification' do
    assert_not(notifications(:inactive).active?)
  end

  # Un-dismissability
  test 'not undismissable' do
    User.current = users(:super_admin)

    assert_not(notifications(:not_dismissable).acknowledge)
    assert_not(notifications(:not_dismissable).acknowledged?)
  end

  # Dismissability/Acknowledgement
  test 'acknowledgement' do
    User.current = users(:super_admin)

    assert(notifications(:notification_1).acknowledge)
    assert(notifications(:notification_1).acknowledged?)
  end
end
