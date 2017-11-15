require 'test_helper'

class ConditionalUserMailerTest < ActiveSupport::TestCase
  include ConditionalUserMailer

  setup do
    @user = User.find_by(email: 'super_admin@example.com')
  end
  test 'raises ArgumentError for a non-valid recipient' do
    e = assert_raises(ArgumentError) do
      deliver_if(recipient: nil, key: nil)
    end
    assert_equal('recipient must be an User object', e.message)
  end
  test 'raises ArgumentError for a non-valid key' do
    e = assert_raises(ArgumentError) do
      deliver_if(recipient: @user, key: nil)
    end
    assert_equal('key must be String', e.message)
  end
  test 'returns false when a block is not given' do
    assert_equal(deliver_if(recipient: @user, key: 'foo'), false)
  end
  test 'returns false when a key is not found under preferences.email' do
    assert_equal(deliver_if(recipient: @user, key: 'foo'){}, false)
  end
  test 'returns false when an email preference is disabled' do
    @user.get_preferences('email')[:users][:new_comment] = false
    assert_equal(deliver_if(recipient: @user, key: 'users.new_comment'){}, false)
  end
  test 'returns true when an email preference is enabled' do
    @user.get_preferences('email')[:users][:new_comment] = true
    assert_equal(deliver_if(recipient: @user, key: 'users.new_comment'){}, true)
  end
  test 'block is executed when an email preference is enabled' do
    @user.get_preferences('email')[:users][:new_comment] = true
    # TODO
  end
end