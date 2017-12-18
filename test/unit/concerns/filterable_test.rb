require 'test_helper'

class FilterableTest < ActiveSupport::TestCase
  test 'raises ArgumentError for a non-hash passed' do
    e = assert_raises(ArgumentError) do
      User.filter(nil)
    end
    assert_equal('hash expected for params', e.message)
  end
  test 'raises ArgumentError for a hash without paginable_all key' do
    e = assert_raises(ArgumentError) do
      User.filter({})
    end
    assert_equal('paginable_all key is expected for params', e.message)
  end
  test 'raises NoMethodError for a non-existing scope method' do
    e = assert_raises(NoMethodError) do
      User.filter({ paginable_all: User.first.org_id, paginable_foo: 'bar' })
    end
  end
  test 'returns ActiveRecord::Relation for values being ActiveRecord::Relation' do
    assert User.filter({ paginable_all: User.first.org.users.includes(:roles), paginable_foo: User.where(nil) }).is_a?(ActiveRecord::Relation)
  end
  test 'returns ActiveRecord::Relation for values being params to scope methods' do
    assert User.filter({ paginable_all: User.first.org_id, paginable_page: 1, paginable_search: "@gmail.com" }).is_a?(ActiveRecord::Relation)
  end
  test 'returns ActiveRecord::Relation for values being ActiveRecord::Relation or params to scope methods' do
    assert User.filter({ paginable_all: User.first.org.users.includes(:roles), paginable_page: 1, paginable_search: "@gmail.com" }).is_a?(ActiveRecord::Relation)
  end
end