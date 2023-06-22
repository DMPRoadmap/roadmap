# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'SuperAdmins Merge Orgs' do
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
    gg = create(:guidance_group, org: @from_org) if gg.blank?
    create(:guidance, guidance_group: gg)
    create(:identifier, identifiable: @from_org, identifier_scheme: nil)
    create(:identifier, identifiable: @from_org, identifier_scheme: @scheme)
    create(:plan, funder: @from_org)
    create(:tracker, org: @from_org)
    create(:user, org: @from_org)

    @to_org = create(:org, :institution, plans: 2, managed: false)

    @user = create(:user, :super_admin, org: create(:org))
    sign_in @user
    visit root_path
  end

  it 'Super admin merges an Org into another Org', :js do
    org_name = @from_org.name
    click_button 'Admin'
    click_link 'Organisations'

    fill_in(:search, with: @from_org.name)
    click_button 'Search'
    sleep(0.3)

    first("#org-#{@from_org.id}-actions").click
    first("a[href=\"/org/admin/#{@from_org.id}/admin_edit\"]").click

    click_link 'Merge'
    sleep(0.3)

    expect(page).to have_text('Merge Organisations')
    select_an_org('#merge-org-controls', @to_org.name, 'Organisation lookup')
    # Commenting out DMPRoadmap logic since we have customized Org selection
    # choose_suggestion('org_org_name', @to_org)

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
    expect(Org.where(name: org_name).any?).to be(false)
    expect(Org.where(name: @to_org.name).any?).to be(true)

    # Make sure the Org we merged is no longer findable
    find_by_id('search').click
    fill_in(:search, with: org_name)
    click_button 'Search'
    sleep(0.3)
    expect(page).to have_text('There are no records associated')

    # Make sure the Org we merged into is findable
    find_by_id('search').click
    fill_in(:search, with: @to_org.name)
    click_button 'Search'
    sleep(0.3)
    expect(page).to have_text(@to_org.name)
  end
end
