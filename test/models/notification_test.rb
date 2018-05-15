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

  # Inactive notification (has not started)
  test 'active notification' do
    assert_includes(Notification.active, notifications(:notification_1))
    assert_not_includes(Notification.active, notifications(:inactive))
  end

  # Un-dismissability
  test 'not dismissable' do
    assert_not(users(:super_admin).acknowledge(notifications(:not_dismissable)))
    assert_not(notifications(:not_dismissable).acknowledged?(users(:super_admin)))
  end

  # Dismissability/Acknowledgement
  test 'acknowledgement' do
    assert(users(:super_admin).acknowledge(notifications(:notification_1)))
    assert(notifications(:notification_1).acknowledged?(users(:super_admin)))
  end
end
