# frozen_string_literal: true

require "rails_helper"

RSpec.feature "ModalSearchDialog", type: :feature do

  include Webmocks

  before(:each) do
    stub_openaire

    @model = create(:repository)
    # TODO: clean this up once we are done with the soft release
    @template = create(:template, allow_research_outputs: true)
    @plan = create(:plan, :creator, org: create(:org), template: @template)
    @user  = @plan.owner
    sign_in(@user)

    click_link @plan.title
    click_link "Research Outputs"
    click_link "Add a research output"
  end

  it "Modal search opens and closes and allows user to search, select and remove items", :js do
    # Open the modal
    click_button "Add a repository"
    expect(page).to have_text("Repository search")

    within("#modal-search-repositories") do
      # Search for the Repository
      fill_in "research_output_search_term",	with: @model.name
      click_button "Apply filter(s)"
      expect(page).to have_text(@model.description)

      # Select the repository and make sure it no longer appears in the search results
      click_link "Select"
      expect(page).not_to have_text(@model.description)

      # Close the modal
      click_button "Close"
    end

    # Verify that the selection was added to the main page's dom
    expect(page).not_to have_text("Repository search")
    expect(page).to have_text(@model.description)
    # Verify that we can remove the selection
    click_link "Remove"
    expect(page).not_to have_text(@model.description)
  end

end
