require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  fixtures :notifications, :notification_types, :users, :perms
  self.use_instantiated_fixtures = true

  # Validity
  test 'valid' do
    assert_equal(true, @valid.valid?)
  end

  # Date validation
  test 'wrong_date' do
    assert_equal(false, @wrong_dates.valid?)
  end

  # Missing parameters
  test 'missing_params' do
    assert_equal(false, @missing_type_id.valid?)
    assert_equal(false, @missing_title.valid?)
    assert_equal(false, @missing_body.valid?)
    assert_equal(false, @missing_level.valid?)
    assert_equal(true, @missing_dismissable.valid?)
    assert_equal(false, @missing_starts_at.valid?)
    assert_equal(false, @missing_expires_at.valid?)
  end

  # Active notification (has started and not expired)
  test 'active notification' do
    n = @valid.clone
    n.update(starts_at: Date.today, expires_at: Date.tomorrow)

    # Not logged in, dismissable Notification
    User.current = nil
    n.update(dismissable: true)
    assert_equal(false, n.active?)

    # Not logged in, undismissable Notification
    n.update(dismissable: false)
    assert_equal(true, n.active?)

    # Logged in, undismissable Notification
    User.current = @super_admin
    assert_equal(true, n.active?)

    # Logged in, dismissable Notification
    n.update(dismissable: true)
    assert_equal(true, n.active?)
  end

  # Inactive notification (has not started)
  test 'inactive notifcation' do
    n = @valid.clone
    n.update(starts_at: Date.tomorrow, expires_at: Date.tomorrow + 1.day)

    assert_equal(false, n.active?)
  end

  # Un-dismissability
  test 'not_dismissable' do
    User.current = @super_admin
    assert_equal(false, @not_dismissable.acknowledge)
  end

  # Dismissability/Acknowledgement
  test 'acknowledged' do
    User.current = @super_admin
    n = @valid.clone
    n.acknowledge

    assert_equal(true, n.acknowledged?)
  end
end
