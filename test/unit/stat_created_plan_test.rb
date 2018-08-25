require 'test_helper'

class StatCreatedPlanTest < ActiveSupport::TestCase

  setup do
    @org = Org.create!(org_seed)
  end

  test '.to_csv returns each StatCreatedPlan object in a comma-separated row' do
    june = StatCreatedPlan.create!(date: Date.new(2018, 06, 30), org: @org, count: 10)
    may = StatCreatedPlan.create!(date: Date.new(2018, 05, 31), org: @org, count: 20)
    data = [june, may]

    csv = StatCreatedPlan.to_csv(data)

    expected_csv = <<~HERE
      date,count
      2018-06-30,10
      2018-05-31,20
    HERE

    assert_equal(csv, expected_csv)
  end
end
