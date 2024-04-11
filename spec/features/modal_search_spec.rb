# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'ModalSearchDialog', type: :feature do
  include Webmocks

  before(:each) do
    stub_openaire

    @model = create(:repository)
    @template = create(:template)
    @plan = create(:plan, :creator, template: @template)
    @user = @plan.owner
    sign_in_as_user(@user)

    Rails.configuration.x.madmp.enable_research_outputs = true
    Rails.configuration.x.madmp.enable_repository_selection = true

    click_link @plan.title
    click_link 'Research Outputs'
    click_link 'Add a research output'
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
      click_link 'Select'
      expect(page).not_to have_text(@model.description)

      # Using JS to click on button, as click_button '.modal-header button.btn-close' did not work.
      modal_close_button = find('.modal-header button.btn-close')
      # Close the modal
      execute_script('arguments[0].click();', modal_close_button)
    end

    # Verify that the selection was added to the main page's dom
    expect(page).not_to have_text('Repository search')
    expect(page).to have_text(@model.description)
    # Verify that we can remove the selection
    click_link 'Remove'
    expect(page).not_to have_text(@model.description)
  end
end
