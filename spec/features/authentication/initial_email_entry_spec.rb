# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in/up via email entry', type: :feature do
  include DmptoolHelper
  include AutocompleteHelper

  before(:each) do
    mock_blog
    @email_domain = "@#{Faker::Lorem.unique.word.downcase}.edu"
    @org = create(:org, contact_email: "#{Faker::Lorem.unique.word}#{@email_domain}")
    visit root_path
  end

  it 'Displays an error if no email is provided', js: true do
    within("form[action=\"#{user_session_path}\"]") do
      expect { find('.is-invalid[id="sign-in-sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
      click_button 'Continue'
      expect(find('.is-invalid[id="sign-in-sign-up-email"]').present?).to eql(true)
    end
  end

  it 'sends known user with an unshibbolized org', js: true do

  end

  it 'sends known user with an shibbolized org', js: true do

  end

  it 'sends unknown user with an unknown email', js: true do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end

  it 'sends unknown user with a known email for an unshibbolized org', js: true do
    fill_in 'Email address', with: "#{Faker::Lorem.unique.word.downcase}#{@email_domain}"
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')

pp page.body

    expect(find('#org_autocomplete_name')).to eql(@org.name)
  end

  it 'sends unknown user with a known email for an shibbolized org', js: true do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
    #'Your address is associated with:'
    #org.name
    #'Sign in with Institution to Continue'
  end
end
