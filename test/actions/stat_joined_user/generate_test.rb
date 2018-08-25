require 'minitest/mock'
require_relative '../../../app/actions/stat_joined_user/generate'

class Actions::StatJoinedUser::GenerateTest < ActiveSupport::TestCase
  setup do
    @org = Org.create!(org_seed.merge({ name: "org#{Random.new.rand(100000)}" }))
    @org.created_at = DateTime.new(2018,04,02,0,0,0)
    @org.save!
  end

  test "full returns monthly aggregates since org's creation" do
    april = [create_user(org: @org, created_at: DateTime.new(2018,04,03,0,0,0)), create_user(org: @org, created_at: DateTime.new(2018,04,04,0,0,0))]
    may = [create_user(org: @org, created_at: DateTime.new(2018,05,01,0,0,0))]
    june = [create_user(org: @org, created_at: DateTime.new(2018,06,01,0,0,0)), create_user(org: @org, created_at: DateTime.new(2018,06,02,0,0,0))]

    Actions::StatJoinedUser::Generate.full(@org)

    april_count = StatJoinedUser.find_by(date: '2018-04-30', org_id: @org.id).count
    may_count = StatJoinedUser.find_by(date: '2018-05-31', org_id: @org.id).count
    june_count = StatJoinedUser.find_by(date: '2018-06-30', org_id: @org.id).count
    july_count = StatJoinedUser.find_by(date: '2018-07-31', org_id: @org.id).count

    assert_equal(2, april_count)
    assert_equal(1, may_count)
    assert_equal(2, june_count)
    assert_equal(0, july_count)
  end

  test "last_month returns aggregates from today's last month" do
    3.times do
      create_user(org: @org, created_at: Date.today.last_month)
    end

    Actions::StatJoinedUser::Generate.last_month(@org)
    
    last_month_count = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: @org.id).count
    assert_equal(3, last_month_count)
  end

  test "full_all_orgs returns monthly aggregates for each org since their creation" do
    april = [create_user(org: @org, created_at: DateTime.new(2018,04,03,0,0,0)), create_user(org: @org, created_at: DateTime.new(2018,04,04,0,0,0))]
    may = [create_user(org: @org, created_at: DateTime.new(2018,05,01,0,0,0))]
    june = [create_user(org: @org, created_at: DateTime.new(2018,06,01,0,0,0)), create_user(org: @org, created_at: DateTime.new(2018,06,02,0,0,0))]

    Org.stub :all, [@org] do
      Actions::StatJoinedUser::Generate.full_all_orgs

      april_count = StatJoinedUser.find_by(date: '2018-04-30', org_id: @org.id).count
      may_count = StatJoinedUser.find_by(date: '2018-05-31', org_id: @org.id).count
      june_count = StatJoinedUser.find_by(date: '2018-06-30', org_id: @org.id).count
      july_count = StatJoinedUser.find_by(date: '2018-07-31', org_id: @org.id).count

      assert_equal(2, april_count)
      assert_equal(1, may_count)
      assert_equal(2, june_count)
      assert_equal(0, july_count)
    end
  end

  test "last_month_all_orgs returns aggregates from today's last month" do
    3.times do
      create_user(org: @org, created_at: Date.today.last_month)
    end

    Org.stub :all, [@org] do
      Actions::StatJoinedUser::Generate.last_month_all_orgs
    
      last_month_count = StatJoinedUser.find_by(date: Date.today.last_month.end_of_month, org_id: @org.id).count
      assert_equal(3, last_month_count)
    end
  end

  def create_user(org: , created_at: DateTime.current)
    user = User.new(user_seed.merge({ org: org, email: "user#{Random.new.rand(100000)}@example.com" }))
    user.save!
    user.created_at = created_at
    user.save!
    user
  end
end
