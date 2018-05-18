require 'test_helper'

class ConditionalUserMailerTest < ActiveSupport::TestCase
  include ConditionalUserMailer

  def save_email_users_new_comment(user, value)
    settings = Pref.default_settings
    settings[:email][:users][:new_comment] = value
    Pref.new(user: user, settings: settings).save
  end

  setup do
    @super_admin = User.find_by(email: 'super_admin@example.com')
    @funder = User.find_by(email: 'funder_admin@example.com')
    @org_admin = User.find_by(email: 'org_admin@example.com')
    @org_user = User.find_by(email: 'org_user@example.com')
  end
  test 'raises ArgumentError for a non-valid key' do
    e = assert_raises(ArgumentError) do
      deliver_if(recipients: @super_admin, key: nil)
    end
    assert_equal('key must be String', e.message)
  end
  test 'returns false when a block is not given' do
    assert_equal(deliver_if(recipients: @super_admin, key: 'foo'), false)
  end
  test 'block is NOT executed when an email preference does not exist' do
    block = false
    assert_equal(deliver_if(recipients: @super_admin, key: 'foo'){ block = true }, true)
    refute block
  end
  test 'block is NOT executed when an email preference is disabled' do
    save_email_users_new_comment(@super_admin, false)
    block = false
    assert_equal(deliver_if(recipients: @super_admin, key: 'users.new_comment') { block = true }, true)
    refute block
  end
  test 'block is executed when an email preference is enabled' do
    save_email_users_new_comment(@super_admin, true)
    block = false
    assert_equal(deliver_if(recipients: @super_admin, key: 'users.new_comment') { block = true }, true)
    assert block
  end
  test 'block is executed for those users from an array with an email preference enabled' do
    save_email_users_new_comment(@super_admin, true)
    save_email_users_new_comment(@funder, false)
    save_email_users_new_comment(@org_admin, false)
    save_email_users_new_comment(@org_user, true)
    block = {}
    recipients = [ @super_admin, @funder, @org_admin, @org_user ]
    assert_equal(deliver_if(recipients: recipients, key: 'users.new_comment') { |r| block[r.email] = true }, true)
    assert_equal({ 'super_admin@example.com' => true, 'org_user@example.com' => true }, block)
  end
  test 'block is executed for those users from an ActiveRecord::Relation with an email preference enabled' do
    users = User.where(id: [@super_admin.id, @funder.id, @org_admin.id, @org_user.id])
    save_email_users_new_comment(users.first, true)
    save_email_users_new_comment(users.second, false)
    save_email_users_new_comment(users.third, false)
    save_email_users_new_comment(users.fourth, true)
    expected = {}
    expected[users.first.email] = true
    expected[users.fourth.email] = true
    block = {}
    assert_equal(deliver_if(recipients: users, key: 'users.new_comment'){ |r| block[r.email] = true }, true)
    assert_equal(expected, block)
  end
end