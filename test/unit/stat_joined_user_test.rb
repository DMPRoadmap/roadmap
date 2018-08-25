require 'test_helper'

class StatJoinedUserTest < ActiveSupport::TestCase

  setup do
    @org = Org.create!(org_seed.merge({ name: "org#{Random.new.rand(100000)}" }))
  end

  test '.monthly_range raises ArgumentError when org is missing' do
    assert_raises(ArgumentError) do
      StatJoinedUser.monthly_range
    end
  end

  test '.monthly_range returns matching records' do
    start_date = Date.new(2018, 04, 30)
    end_date = Date.new(2018, 05, 31)
    june = StatJoinedUser.create!(date: Date.new(2018, 06, 30), org: @org)
    may = StatJoinedUser.create!(date: end_date, org: @org)
    april = StatJoinedUser.create!(date: start_date, org: @org)
    
    actual = StatJoinedUser.monthly_range(org: @org, start_date: start_date, end_date: end_date).to_a

    assert_includes(actual, april)
    assert_includes(actual, may)
    refute_includes(actual, june)
  end

  test '.to_csv returns each StatJoinedUser object in a comma-separated row' do
    june = StatJoinedUser.create!(date: Date.new(2018, 06, 30), org: @org, count: 5)
    may = StatJoinedUser.create!(date: Date.new(2018, 05, 31), org: @org, count: 6)
    data = [june, may]

    csv = StatJoinedUser.to_csv(data)

    expected_csv = <<~HERE
      date,count
      2018-06-30,5
      2018-05-31,6
    HERE

    assert_equal(csv, expected_csv)
  end
end
