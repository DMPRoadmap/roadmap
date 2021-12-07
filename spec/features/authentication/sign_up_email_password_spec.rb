# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign up via email and password', type: :feature do
  include DmptoolHelper
  include AutoCompleteHelper

  before(:each) do
    # -------------------------------------------------------------
    # start DMPTool customization
    # Mock the blog feed on our homepage
    # -------------------------------------------------------------
    mock_blog
    # -------------------------------------------------------------
    # end DMPTool customization
    # -------------------------------------------------------------

    @non_ror_org = create(:org)
    @ror_org = create(:org)
    @registry_org = create(:registry_org)
    @known_registry_org = create(:registry_org, org: @ror_org)

    visit root_path
    click_link 'Create account'
  end

  scenario 'User does not fill out all required fields', :js do
    within('#create_account_form') do
      expect(page).not_to have_text('Please fill out all of the required fields.')

      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      fill_in 'Email', with: Faker::Internet.unique.email
      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      select_an_org('#create-account-org-controls', @non_ror_org.name)
      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      fill_in 'Password', with: SecureRandom.uuid
      click_button 'Create account'
      expect(page).to have_text('Please fill out all of the required fields.')

      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end

  scenario 'Does not allow user to enter a random Org into autocomplete' do
    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      select_an_org('#create-account-org-controls', Faker::Lorem.sentence)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text('Please fill out all of the required fields.')
  end

  scenario 'Allows user to select an Org that exists but is not a ROR Org' do
    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      select_an_org('#create-account-org-controls', @non_ror_org.name)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end

  scenario 'Allows user to select an Org that exists and is a ROR Org' do
    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      select_an_org('#create-account-org-controls', @known_registry_org.name)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end

  scenario 'Allows user to select a RegistryOrg that is not yet an Org' do
    Rails.configuration.x.application.restrict_orgs = false

    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      select_an_org('#create-account-org-controls', @registry_org.name)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end

  scenario 'Does not allow user to select a RegistryOrg with no Org if restrict_orgs is false' do
    Rails.configuration.x.application.restrict_orgs = true

    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      select_an_org('#create-account-org-controls', @registry_org.name)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(root_path)
    expect(page).to have_text('Unable to create your account.')
    expect(page).to have_text('Org must exist')
  end

  scenario 'Allows user to specify a custom Org name' do
    within('#create_account_form') do
      click_button 'Create account'
      fill_in 'First Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Last Name', with: Faker::Movies::StarWars.character.split(' ').first
      fill_in 'Email', with: Faker::Internet.unique.email
      enter_custom_org('#create-account-org-controls', Faker::Movies::StarWars.planet)
      fill_in 'Password', with: SecureRandom.uuid
      check 'I accept the terms and conditions'
      click_button 'Create account'
    end

    expect(current_path).to eql(plans_path)
    expect(page).to have_text('Welcome')
    expect(page).to have_text('You are now ready to create your first DMP.')
  end
end
