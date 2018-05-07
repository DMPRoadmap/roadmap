require 'test_helper'

class NotificationAcknowledgementTest < ActiveSupport::TestCase
  fixtures :users, :notifications

  test 'has' do
    assert(NotificationAcknowledgement.has?(
      users(:super_admin),
      notifications(:notification_1)
    ))
  end
end
