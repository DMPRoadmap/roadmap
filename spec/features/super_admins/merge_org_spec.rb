# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SuperAdmins Merge Orgs', type: :feature do
  before do
    Org.destroy_all
    @scheme = create(:identifier_scheme)
    tpt = create(:token_permission_type)
    @from_org = create(:org, :organisation, templates: 1, plans: 2, managed: true,
                                            feedback_enabled: true,
                                            token_permission_types: [tpt])
    create(:annotation, org: @from_org)
    create(:department, org: @from_org)
    gg = @from_org.guidance_groups.first if @from_org.guidance_groups.any?
    gg = create(:guidance_group, org: @from_org) unless gg.present?
    create(:guidance, guidance_group: gg)
    create(:identifier, identifiable: @from_org, identifier_scheme: nil)
    create(:identifier, identifiable: @from_org, identifier_scheme: @scheme)
    create(:plan, funder: @from_org)
    create(:tracker, org: @from_org)
    create(:user, org: @from_org)

    @to_org = create(:org, :institution, plans: 2, managed: false)

    @user = create(:user, :super_admin, org: create(:org))
    sign_in(@user)
  end

  scenario 'Super admin merges an Org into another Org', :js do
    org_name = @from_org.name
    click_link 'Admin'
    sleep(0.5)
    click_link 'Organisations'

    fill_in(:search, with: @from_org.name)
    click_button 'Search'
    sleep(0.5)

    first("#org-#{@from_org.id}-actions").click
    first("a[href=\"/org/admin/#{@from_org.id}/admin_edit\"]").click

    click_link 'Merge'
    sleep(0.3)
    expect(page).to have_text('Merge Organisations')
    choose_suggestion('org_org_name', @to_org)

    click_button 'Analyze'
    # Wait for response
    sleep(0.3)
    expect(page).to have_text('Summary:')

    click_button 'Merge records'
    # Wait for redirect
    sleep(0.3)
    expect(page).to have_text('Organisations')
    expect(page).to have_text('Successfully merged')

    # Make sure that the correct org was deleted
    expect(Org.where(name: org_name).any?).to eql(false)
    expect(Org.where(name: @to_org.name).any?).to eql(true)

    # Make sure the Org we merged is no longer findable
    find('#search').click
    fill_in(:search, with: org_name)
    click_button 'Search'
    sleep(0.3)
    expect(page).to have_text('There are no records associated')

    # Make sure the Org we merged into is findable
    find('#search').click
    fill_in(:search, with: @to_org.name)
    click_button 'Search'
    sleep(0.3)
    expect(page).to have_text(@to_org.name)
  end
end
