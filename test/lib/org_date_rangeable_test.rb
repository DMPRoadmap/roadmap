class OrgDateRangeableTest < ActiveSupport::TestCase

  setup do
    @org = Org.create!(org_seed)
    @org.created_at = DateTime.new(2018,05,27, 0,0,0)
    @org.save!
  end

  test 'classes which include respond to monthly_range' do
    included = [StatJoinedUser, StatCreatedPlan]

    included.each do |klass|
      assert_respond_to(klass, :monthly_range)
    end
  end

  test ".split_months_from_creation starts at org's created_at" do
    expected_start_date = @org.created_at.to_i

    OrgDateRangeable.split_months_from_creation(@org) do |start_date|
      assert_equal(start_date.to_i, expected_start_date)
      break
    end
  end

  test ".split_months_from_creation finishes at today's last month" do
    expected_end_date = DateTime.current.last_month.end_of_month.to_i
    actual_end_date = nil

    OrgDateRangeable.split_months_from_creation(@org) do |start_date, end_date|
      actual_end_date = end_date
    end

    assert_equal(actual_end_date.to_i, expected_end_date)
  end

  test '.split_months_from_creation returns Enumerable' do
    enumerable = OrgDateRangeable.split_months_from_creation(@org)

    assert_respond_to(enumerable, :each)
    start_date = @org.created_at.to_i
    end_date = DateTime.new(2018,05,31,23,59,59).to_i
    first_start_date = enumerable.first[:start_date].to_i
    first_end_date = enumerable.first[:end_date].to_i
    assert_equal(first_start_date, start_date)
    assert_equal(first_end_date, end_date)
  end
end
