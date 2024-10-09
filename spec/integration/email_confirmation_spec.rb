# frozen_string_literal: true

require 'rails_helper'

# For testing the custom email confirmation UX flow
# (See `app/controllers/concerns/email_confirmation_handler.rb`)
# Here, we define "unconfirmable" as a user that is both unconfirmed and has no outstanding confirmation token
RSpec.describe 'Email Confirmation', type: :feature do
  scenario 'A user attempts to sign in via the "Sign In" button. However, they are unconfirmable.', :js do
    # Setup
    user = create(:user, :unconfirmable)

    # Actions
    sign_in(user)
    user.reload

    # Expectations
    expectations_for_unconfirmable_user_after_sign_in_attempt(user)
  end

  scenario 'A user attempts to sign in via the "Sign in with institutional or social ID"
            button with an email that is not currently linked to any account. The chosen
            SSO email matches an existing user account email. However, they are unconfirmable.', :js do
    # Setup
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:openid_connect]
    user = create(:user, :unconfirmable, email: OmniAuth.config.mock_auth[:openid_connect][:info][:email])

    # Actions
    visit root_path
    click_link 'Sign in with institutional or social ID'
    user.reload

    # Expectations
    expectations_for_unconfirmable_user_after_sign_in_attempt(user)
    # An Identifier entry was not created
    expect(Identifier.count).to be_zero
  end

  private

  def expectations_for_unconfirmable_user_after_sign_in_attempt(user)
    # The user remains unconfirmed
    expect(user.confirmed?).to be(false)
    # A confirmation_token now exists
    expect(user.confirmation_token).to be_present
    # The user is not signed in
    expect(current_path).to eq(root_path)
  end
end
