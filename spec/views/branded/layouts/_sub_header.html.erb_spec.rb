# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/_sub_header.html.erb' do
  include Helpers::DmptoolHelper

  before do
    controller.prepend_view_path 'app/views/branded'
    @org = create(:org)
  end

  it 'renders the Org logo if present' do
    sign_in create(:user, org: @org)
    logo = OpenStruct.new({ present?: true })
    logo.stubs(:url).returns(Faker::Internet.url)
    @org.stubs(:logo).returns(logo)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-logo-org"')).to be(true)
    expect(rendered.include?('<img')).to be(true)
  end

  it 'renders the Org name if no logo is present' do
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-logo-org"')).to be(true)
    expect(rendered.include?(CGI.escapeHTML(@org.name))).to be(true)
  end

  it 'does not render the Admin menu if user is not an Org Admin or Super Admin' do
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('id="js-admin"')).to be(false)
  end

  it 'renders the Admin menu if user is an Org Admin' do
    sign_in create(:user, :org_admin, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('id="js-admin"')).to be(true)
    expect(rendered.include?('Guidance</a>')).to be(true)
    expect(rendered.include?('Organisation details</a>')).to be(true)
    expect(rendered.include?('Plans</a>')).to be(true)
    expect(rendered.include?('Templates</a>')).to be(true)
    expect(rendered.include?('Usage</a>')).to be(true)
    expect(rendered.include?('Users</a>')).to be(true)

    expect(rendered.include?('Api Clients</a>')).to be(false)
    expect(rendered.include?('Notifications</a>')).to be(false)
    expect(rendered.include?('Organisations</a>')).to be(false)
    expect(rendered.include?('Themes</a>')).to be(false)
  end

  it 'renders the Admin menu if user is a Super Admin' do
    sign_in create(:user, :super_admin, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('id="js-admin"')).to be(true)
    expect(rendered.include?('Guidance</a>')).to be(true)
    expect(rendered.include?('Plans</a>')).to be(true)
    expect(rendered.include?('Templates</a>')).to be(true)
    expect(rendered.include?('Usage</a>')).to be(true)
    expect(rendered.include?('Users</a>')).to be(true)
    expect(rendered.include?('Api Clients</a>')).to be(true)
    expect(rendered.include?('Notifications</a>')).to be(true)
    expect(rendered.include?('Organisations</a>')).to be(true)
    expect(rendered.include?('Themes</a>')).to be(true)

    expect(rendered.include?('Organisation details</a>')).to be(false)
  end

  it 'does not render the Org links if none are defined' do
    @org.links = { org: [] }
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-links-org"')).to be(false)
  end

  it 'renders the Org links' do
    links = { org: [{ link: Faker::Internet.url, text: Faker::Lorem.word }] }
    @org.links = links
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-links-org"')).to be(true)
    expect(rendered.include?("href=\"#{links[:org].first[:link]}\"")).to be(true)
    expect(rendered.include?("#{links[:org].first[:text]}</a>")).to be(true)
  end

  it 'does not render the Org contact email if it is not defined' do
    @org.links = { org: [{ link: Faker::Internet.url, text: Faker::Lorem.word }] }
    @org.contact_email = nil
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-links-org__uc3-helpdesk"')).to be(false)
  end

  it 'renders the Org contact email' do
    @org.links = { org: [{ link: Faker::Internet.url, text: Faker::Lorem.word }] }
    sign_in create(:user, org: @org)
    render template: '/layouts/_sub_header', locals: { org: @org }
    expect(rendered.include?('class="c-links-org__uc3-helpdesk"')).to be(true)
    expect(rendered.include?("href=\"mailto:#{@org.contact_email}\"")).to be(true)
    expect(rendered.include?("#{CGI.escapeHTML(@org.contact_name)}</a>")).to be(true)
  end
end
