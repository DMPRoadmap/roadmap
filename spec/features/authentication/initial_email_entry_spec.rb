# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sign in/up via email entry', type: :feature do
  include DmptoolHelper
  include AutocompleteHelper

  before(:each) do
    mock_blog
    @org = create(:org)
    visit root_path
  end

  it 'Displays an error if no email is provided' do
    within("form[action=\"#{user_session_path}\"]") do
      expect { find('.is-invalid[id="sign-up-email"]') }.to raise_error(Capybara::ElementNotFound)
      click_button 'Continue'
      expect(find('.is-invalid[id="sign-up-email"]').present?).to eql(true)
    end
  end

  it 'sends known user with an unshibbolized org to the sign in form' do

  end

  it 'sends known user with an shibbolized org to the SSO sign in form' do

  end

  it 'sends unknown user with an unknown email domain to the sign up form' do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end

  it 'sends unknown user with a known email domain for an unshibbolized org get the sign up form' do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end

  it 'sends unknown user with a known email domain for an shibbolized org get the SSO sign up form' do
    fill_in 'Email address', with: Faker::Internet.unique.email
    click_on 'Continue'

    expect(page).to have_text('New Account Sign Up')
  end
end
