# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign up via email and password', type: :feature do
  include DmptoolHelper
  include AutocompleteHelper

  before(:each) do
    mock_blog

    @non_ror_org = create(:org)
    @ror_org = create(:org)
    @registry_org = create(:registry_org)
    @known_registry_org = create(:registry_org, org: @ror_org)

    visit root_path
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end

  context 'form validations' do
    it 'displays top level error message displays', :js do
      click_button 'Sign up'
      expect(page).to have_text('Please correct the fields below:')
    end

    scenario 'User does not fill out any fields', :js do
      within("form[action=\"#{user_registration_path}\"]") do
        # There should be no errors on initial page load
        expect { find('.is-invalid[id="sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-firstname"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-surname"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-org"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="js-password-field"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-accept-terms"]') }.to raise_error(Capybara::ElementNotFound)

        click_button 'Sign up'

        # Should report missing :firstname, :surname, :org, :password and :accept_terms
        expect { find('.is-invalid[id="sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
        expect(find('.is-invalid[id="sign-up-firstname"]').present?).to eql(true)
        expect(find('.is-invalid[id="sign-up-surname"]').present?).to eql(true)
        expect(find('.is-invalid[id="sign-up-org"]').present?).to eql(true)
        expect(find('.is-invalid[id="js-password-field"]').present?).to eql(true)
        expect(find('.is-invalid[id="sign-up-accept-terms"]').present?).to eql(true)
        expect(all('.is-invalid').length).to eql(5)
      end
    end

    scenario 'User provides everything but a valid institution', :js do
      within("form[action=\"#{user_registration_path}\"]") do
        fill_in 'First Name', with: Faker::Movies::StarWars.character.split.first
        fill_in 'Last Name', with: Faker::Movies::StarWars.character.split.last
        fill_in 'Password', with: SecureRandom.uuid
        # Need to use JS to set the accept terms label since dmptool-ui treats the
        # whole thing as a label and theis particular label has a URL so 'clicking' it
        # via Capybara results in going to the URL behind that link :/
        page.execute_script("document.getElementById('user_accept_terms').checked = true;")

        click_button 'Sign up'

        # Should report missing :surname, :org, :password and :accept_terms
        expect { find('.is-invalid[id="sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-firstname"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="js-password-field"]') }.to raise_error(Capybara::ElementNotFound)
        expect { find('.is-invalid[id="sign-up-accept-terms"]') }.to raise_error(Capybara::ElementNotFound)
        expect(find('.is-invalid[id="sign-up-org"]').present?).to eql(true)
        expect(all('.is-invalid').length).to eql(1)
      end
    end

    scenario 'User fills out all required fields', js: true do
      within("form[action=\"#{user_registration_path}\"]") do
        fill_in 'First Name', with: Faker::Movies::StarWars.character.split.first
        fill_in 'Last Name', with: Faker::Movies::StarWars.character.split.last
        select_an_org('#sign-up-org', @non_ror_org.name, 'Institution')
        fill_in 'Password', with: SecureRandom.uuid
        # Need to use JS to set the accept terms label since dmptool-ui treats the
        # whole thing as a label and theis particular label has a URL so 'clicking' it
        # via Capybara results in going to the URL behind that link :/
        page.execute_script("document.getElementById('user_accept_terms').checked = true;")
        click_button 'Sign up'
      end

      expect(current_path).to eql(plans_path)
      expect(page).to have_text('Welcome')
      expect(page).to have_text('You are now ready to create your first DMP.')
    end
  end

  context 'Validate various Org types', js: true do
    before(:each) do
      within("form[action=\"#{user_registration_path}\"]") do
        fill_in 'First Name', with: Faker::Movies::StarWars.character.split.first
        fill_in 'Last Name', with: Faker::Movies::StarWars.character.split.last
        fill_in 'Password', with: SecureRandom.uuid
        page.execute_script("document.getElementById('user_accept_terms').checked = true;")
      end
    end

    scenario 'Does not allow user to enter a random Org into autocomplete' do
      within("form[action=\"#{user_registration_path}\"]") do
        fill_in 'Institution', with: Faker::Lorem.sentence
        fill_in 'Password', with: SecureRandom.uuid
        click_button 'Sign up'
        expect(find('.is-invalid[id="sign-up-org"]').present?).to eql(true)
      end
    end

    scenario 'Allows user to select an Org that exists but is not a ROR Org' do
      within("form[action=\"#{user_registration_path}\"]") do
        select_an_org('#sign-up-org', @non_ror_org.name, 'Institution')
        click_button 'Sign up'
      end
      expect(current_path).to eql(plans_path)
      expect(page).to have_text('Welcome')
      expect(page).to have_text('You are now ready to create your first DMP.')
    end

    scenario 'Allows user to select an Org that exists and is a ROR Org' do
      within("form[action=\"#{user_registration_path}\"]") do
        select_an_org('#sign-up-org', @known_registry_org.name, 'Institution')
        click_button 'Sign up'
      end

      expect(current_path).to eql(plans_path)
      expect(page).to have_text('Welcome')
      expect(page).to have_text('You are now ready to create your first DMP.')
    end

    scenario 'Allows user to select a RegistryOrg that is not yet an Org' do
      Rails.configuration.x.application.restrict_orgs = false

      within("form[action=\"#{user_registration_path}\"]") do
        select_an_org('#sign-up-org', @registry_org.name, 'Institution')
        click_button 'Sign up'
      end

      expect(current_path).to eql(plans_path)
      expect(page).to have_text('Welcome')
      expect(page).to have_text('You are now ready to create your first DMP.')
    end

    scenario 'Does not allow user to select a RegistryOrg with no Org if restrict_orgs is false' do
      Rails.configuration.x.application.restrict_orgs = true

      within("form[action=\"#{user_registration_path}\"]") do
        fill_in 'Institution', with: @registry_org.name
        click_button 'Sign up'
        expect(find('.is-invalid[id="sign-up-org"]').present?).to eql(true)
      end
    end

    scenario 'Allows user to specify a custom Org name' do
      Rails.configuration.x.application.restrict_orgs = false

      within("form[action=\"#{user_registration_path}\"]") do

p '================================================='
p 'CUSTOM ORG ENTRY'
p "Restrict Orgs? #{Rails.configuration.x.application.restrict_orgs}, "
p '================================================='
pp page.body

        enter_custom_org('#sign-up-org', Faker::Movies::StarWars.planet)
        click_button 'Sign up'
      end

      expect(current_path).to eql(plans_path)
      expect(page).to have_text('Welcome')
      expect(page).to have_text('You are now ready to create your first DMP.')
    end
  end
end
