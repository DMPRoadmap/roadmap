require 'test_helper'

class JSONLinkValidatorTest < ActiveSupport::TestCase
  include JSONLinkValidator

  test 'returns nil for a non-string value passed' do
    assert_nil(parse_links(nil))
    assert_nil(parse_links(true))
    assert_nil(parse_links(false))
    assert_nil(parse_links([]))
    assert_nil(parse_links({}))
    assert_nil(parse_links(1))
    assert_nil(parse_links(1.1))
  end

  test 'returns nil for a non-array object parsed' do
    assert_nil(parse_links("string"))
    assert_nil(parse_links("1"))
    assert_nil(parse_links("{}"))
    assert_nil(parse_links("true"))
    assert_nil(parse_links("false"))
    assert_nil(parse_links("null"))
    assert(parse_links("[]"))
  end 

  test 'returns nil for a non-hash item within the array parsed' do
    assert_nil(parse_links("[{}, \"\"]"))
  end

  test 'returns nil for a non-valid link key at array item' do
    assert_nil(parse_links("[{\"link\": \"\", \"text\": \"\"}, {}]"))
  end

  test 'returns nil for a non-valid text key at array item' do
    assert_nil(parse_links("[{\"link\": \"\", \"text\": \"\"}, {\"link\": \"\"}]"))
  end

  test 'returns nil for a non-string value for link key at array item' do
    assert_nil(parse_links("[{\"link\": \"\", \"text\": \"\"}, {\"link\": [], \"text\": \"\"}]"))
  end

  test 'returns nil for a non-string value for a text key at array item' do
    assert_nil(parse_links("[{\"link\": \"\", \"text\": \"\"}, {\"link\": \"\", \"text\": []}]"))
  end

  test 'returns Array for a valid array of link objects' do
    assert_equal([{ "link" => "", "text" => ""}, { "link" => "", "text" => ""}],
      parse_links("[{\"link\": \"\", \"text\": \"\"}, {\"link\": \"\", \"text\": \"\"}]"))
  end
end