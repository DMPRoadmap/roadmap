# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SuperAdmins Orgs', js: true do
  include Helpers::LinksHelper

  before do
    @org = create(:org)
    @user = create(:user, :super_admin, org: @org)
    sign_in @user
    visit root_path
  end

  it 'Super admin adds links' do
    click_button 'Admin'
    click_link 'Organisations'
    first('td .dropdown button').click
    first('.dropdown-menu > li > a').click
    nbr_links = all('.link').length
    add_link
    expect(all('.link').length).to eql(nbr_links + 1)
  end

  it 'Super admin removes links' do
    click_button 'Admin'
    click_link 'Organisations'
    # Edit the first org in the table
    find('table .dropdown-toggle').click
    find('.dropdown-menu > li > a').click
    add_link
    nbr_links = all('.link').length
    remove_link
    expect(all('.link').length).to eql(nbr_links - 1)
  end
end
