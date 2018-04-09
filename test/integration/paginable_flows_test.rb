require 'test_helper'

class PaginableFlowsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.find_by(email: 'super_admin@example.com')
    sign_in @user
  end

  test 'when total greather than default_per_page pagination and searchable/paginable are enabled' do
    create_users(Kaminari.config.default_per_page+1)
    get(index_paginable_users_path(1)+"?search=User")
    # Fails if search form does not exists under paginable-search
    refute_empty(css_select('.paginable-search form'))
    # Fails if sort link for email does not exist
    refute_empty(css_select('a[href$="1?search=User&sort_field=email&sort_direction=ASC"]'))
    # Fails if sort link for last_sign_in_at does not exist
    refute_empty(css_select('a[href$="1?search=User&sort_field=last_sign_in_at&sort_direction=ASC"]'))

    link_view_all_search_results = css_select('a[href$="/ALL?search=User"]').first
    refute_nil(link_view_all_search_results)
    assert_equal(link_view_all_search_results.content, _('View all search results'))

    link_clear_search_results = css_select('a[href$="/1"]').first
    refute_nil(link_clear_search_results)
    assert_equal(link_clear_search_results.content, _('Clear search results'))

    # Fails if pagination nav is not found
    refute_empty(css_select('nav.pagination'))
  end

  test 'when total greather than default_per_page pagination and searchable/not paginable are enabled' do
    create_users(Kaminari.config.default_per_page+1)
    get(index_paginable_users_path('ALL')+"?search=User")
    # Fails if search form does not exists under paginable-search
    refute_empty(css_select('.paginable-search form'))
    # Fails if sort link for email does not exist
    refute_empty(css_select('a[href$="ALL?search=User&sort_field=email&sort_direction=ASC"]'))
    # Fails if sort link for last_sign_in_at does not exist
    refute_empty(css_select('a[href$="ALL?search=User&sort_field=last_sign_in_at&sort_direction=ASC"]'))

    link_view_less_search_results = css_select('a[href$="/1?search=User"]').first
    refute_nil(link_view_less_search_results)
    assert_equal(link_view_less_search_results.content, _('View less search results'))

    link_clear_search_results = css_select('a[href$="/1"]').first
    refute_nil(link_clear_search_results)
    assert_equal(link_clear_search_results.content, _('Clear search results'))

    # Fails if pagination nav is found
    assert_empty(css_select('nav.pagination'))
  end

  test 'when total greather than default_per_page pagination and not searchable/paginable are enabled' do
    create_users(Kaminari.config.default_per_page)
    get(index_paginable_users_path(1))
    # Fails if search form does not exists under paginable-search
    refute_empty(css_select('.paginable-search form'))
    # Fails if sort link for email does not exist
    refute_empty(css_select('a[href$="1?sort_field=email&sort_direction=ASC"]'))
    # Fails if sort link for last_sign_in_at does not exist
    refute_empty(css_select('a[href$="1?sort_field=last_sign_in_at&sort_direction=ASC"]'))
    # Super admins are not able to see View All link
    link = css_select('a[href$="/ALL"]').first
    assert_nil(link)

    # Fails if pagination nav is not found
    refute_empty(css_select('nav.pagination'))
  end

  test 'when total less than default_per_page pagination and searchable is enabled and no records found' do
    get(index_paginable_users_path(1)+"?search=foo")
    # Fails if search form does not exists under paginable-search
    refute_empty(css_select('.paginable-search form'))

    message = css_select('p.bg-info').first
    # Fails if there is not contextual background message
    refute_nil(message)
    assert_equal(message.content.strip, _('There are no records associated'))

    link = css_select('a[href$="/1"]').first
    # Fails if link ending with /1 does not exist. Note, used to clear results
    refute_nil(link)
    assert_equal(link.content, _('Clear search results'))
  end

  test 'when total less than default_per_page pagination and searchable is enabled' do
    create_users(Kaminari.config.default_per_page)
    get(index_paginable_users_path(1)+"?search=User")
    # Fails if search form does not exists under paginable-search
    refute_empty(css_select('.paginable-search form'))

    message = css_select('p.bg-info').first
    assert_nil(message)

    link = css_select('a[href$="/1"]').first
    # Fails if link ending with /1 does not exist. Note, used to clear results
    refute_nil(link)
    assert_equal(link.content, _('Clear search results'))
  end

  test 'returns forbidden status when view_all option is false' do
    create_users(Kaminari.config.default_per_page)
    get(index_paginable_users_path('ALL'))
    assert_response(:forbidden)
    assert_equal(_('Restricted access to View All the records'), response.body)
  end

  teardown do
    User.where('email LIKE ?', "user%@example.com").destroy_all
  end

  private
    def create_users(number)
      language = Language.find_by(abbreviation: FastGettext.locale)
      (1..number).each do |i|
        u = User.new({
          email: "user#{i}@example.com", firstname: "User", surname: "#{i}",
          password: "password123", password_confirmation: "password123", org: @user.org,
          language: language, accept_terms: true, confirmed_at: Time.zone.now }).save
      end 
    end
end