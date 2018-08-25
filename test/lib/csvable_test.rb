require 'test_helper'

class CsvableTest < ActiveSupport::TestCase
  test '.from_array_of_hashes return empty string' do
    data = []

    stringified_csv = Csvable.from_array_of_hashes(data)

    assert_empty(stringified_csv)
  end

  test '.from_array_of_hashes return first row with columns for each hash key' do
    data = [{ column1: 'value row1.1', column2: 'value row1.2' }]

    stringified_csv = Csvable.from_array_of_hashes(data)
    header = /[^\n]*/.match(stringified_csv)[0]

    assert_equal("column1,column2", header)
  end

  test '.from_array_of_hashes returns a row for each hash within the array' do
    data = [
      { column1: 'value row1.1', column2: 'value row1.2' },
      { column1: 'value row2.1', column2: 'value row2.2' },
      { column1: 'value row3.1', column2: 'value row3.2' },
    ]

    stringified_csv = Csvable.from_array_of_hashes(data)
    expected_data = <<~HERE
      column1,column2
      value row1.1,value row1.2
      value row2.1,value row2.2
      value row3.1,value row3.2
    HERE

    assert_equal(expected_data, stringified_csv)
  end
end
