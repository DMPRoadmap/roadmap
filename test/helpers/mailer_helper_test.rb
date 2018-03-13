require 'test_helper'

class MailerHelperTest < ActionView::TestCase
  setup do
    @user = User.find_by(email: "super_admin@example.com")
    @user.perms.destroy_all
  end
  test "returns nil when objects does not have a method perms" do
    assert_nil privileges_list({})
  end
  test "returns an empty ul list for an user without permissions" do
    assert_equal("<ul></ul>", privileges_list(@user))
  end
  test "return an ul list with the permission for an user" do
    names = name_and_text # PermsHelper method included within MailerHelper
    @user.perms << Perm.first
    @user.perms << Perm.second
    @user.save
    expected="<ul><li>#{names[Perm.first.name.to_sym]}</li><li>#{names[Perm.second.name.to_sym]}</li></ul>"
    assert_equal(expected, privileges_list(@user))
  end
end