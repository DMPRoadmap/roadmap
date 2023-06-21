# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ModalSearchDialog' do
  include Helpers::Webmocks

  before do
    stub_openaire

    @model = create(:repository)
    @template = create(:template)
    @plan = create(:plan, :creator, template: @template)
    @user = @plan.owner
    sign_in @user
    visit root_path

    @original_outputs = Rails.configuration.x.madmp.enable_research_outputs
    @original_repos = Rails.configuration.x.madmp.enable_repository_selection
    Rails.configuration.x.madmp.enable_research_outputs = true
    Rails.configuration.x.madmp.enable_repository_selection = true

    click_link @plan.title
    click_link 'Research outputs'
    click_link 'Add a research output'
  end

  after do
    Rails.configuration.x.madmp.enable_research_outputs = @original_outputs
    Rails.configuration.x.madmp.enable_repository_selection = @original_repos
  end

  it 'Modal search opens and closes and allows user to search, select and remove items', :js do
    # Open the modal
    click_button 'Add a repository'
    expect(page).to have_text('Repository search')

    within('#modal-search-repositories') do
      # Search for the Repository
      fill_in 'research_output_search_term',	with: @model.name
      click_button 'Apply filter(s)'
      expect(page).to have_text(@model.description)

      # Select the repository and make sure it no longer appears in the search results
      click_button 'Select'
      expect(page).not_to have_text(@model.description)

      # Close the modal
      click_button 'Close'
    end

    # Verify that the selection was added to the main page's dom
    expect(page).not_to have_text('Repository search')
    expect(page).to have_text(@model.description)
    # Verify that we can remove the selection
    click_button 'Remove'
    expect(page).not_to have_text(@model.description)
  end
end
