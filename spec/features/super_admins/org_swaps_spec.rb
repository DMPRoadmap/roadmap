# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SuperAdmins OrgSwaps', type: :feature, js: true do
  before do
    @org1, @org2 = *create_list(:org, 2, managed: true)
  end

  scenario 'Org admin attempts to change to new org' do
    @user = create(:user, :org_admin, org: @org1)
    sign_in @user
    visit root_path
    click_button 'Admin'
    click_link 'Templates'
    expect(page).not_to have_text('Change affiliation')
  end

  scenario 'Super admin changes to new org' do
    @user = create(:user, :super_admin, org: @org1)
    sign_in @user
    visit root_path
    click_button 'Admin'
    click_link 'Templates'
    select_an_org('#change-affiliation-org-controls', @org2.name, 'Affiliation')
    click_button 'Change affiliation'
    expect(current_path).to eql(org_admin_templates_path)
    expect(page).to have_text(@org2.name)
    expect(page).not_to have_text(@org1.name)
    expect(@user.reload.org).to eql(@org2)
  end
end
