# frozen_string_literal: true

require 'rails_helper'
SSO_SIGN_IN_BUTTON_TEXT = 'Sign in with your institutional credentials'

# For testing the custom email confirmation UX flow for unconfirmed users with no outstanding confirmation_token
RSpec.describe 'Email Confirmation', type: :feature do
  include OmniAuthHelper

  scenario 'A user attempts to sign in via the "Sign In" button.
            However, they are unconfirmed and have no confirmation_token.', :js do
    user = create(:user, :unconfirmed_and_no_confirmation_token)

    # Sign-in attempt #1 (user is unconfirmed and has no confirmation_token)
    sign_in(user)
    expectations_for_unconfirmed_user_with_no_confirmation_token_after_sign_in_attempt(user)

    # Sign-in attempt #2 (user still unconfirmed but has a confirmation_token)
    sign_in(user)
    expectations_for_unconfirmed_user_with_confirmation_token_after_sign_in_attempt

    # Sign-in attempt #3 (user is now confirmed)
    user.confirm
    sign_in(user)
    # The user is signed in
    expect(page).to have_current_path(plans_path)
  end

  describe 'Initial setup for shibboleth sign-in' do
    before do
      # Set up the user and identifier scheme
      @user = create(:user, :unconfirmed_and_no_confirmation_token)
      scheme = create(:identifier_scheme, :shibboleth)
      # Mock OmniAuth authentication hash for Shibboleth via OmniAuthHelper
      OmniAuth.config.mock_auth[:shibboleth] = mock_auth_hash(@user, scheme)
      # Explicitly define a Users::OmniauthCallbacksController action for the scheme
      define_omniauth_callback_for(scheme)

      # Create the identifier for the user
      Identifier.create(identifier_scheme: scheme,
                        value: OmniAuth.config.mock_auth[:shibboleth].uid,
                        attrs: OmniAuth.config.mock_auth[:shibboleth],
                        identifiable: @user)
    end

    scenario 'A user attempts to sign in via the "Sign in with your institutional credentials"
              button. The email is linked to a user account, however the account is
              unconfirmed and has no confirmation token.', :js do
      visit root_path
      # Sign-in attempt #1 (user is unconfirmed and has no confirmation_token)
      click_link SSO_SIGN_IN_BUTTON_TEXT
      expectations_for_unconfirmed_user_with_no_confirmation_token_after_sign_in_attempt(@user)

      visit root_path
      # Sign-in attempt #2 (user still unconfirmed but has a confirmation_token)
      click_link SSO_SIGN_IN_BUTTON_TEXT
      expectations_for_unconfirmed_user_with_confirmation_token_after_sign_in_attempt

      # Sign-in attempt #3 (user is now confirmed)
      @user.confirm
      click_link SSO_SIGN_IN_BUTTON_TEXT
      # The user is signed in
      expect(page).to have_current_path(plans_path)
    end
  end

  scenario 'A user is unconfirmed but has no confirmation token.
            There sign in attempt fails, and a custom flash message
            is rendered that can be used to navigate to the confirmation page.', :js do
    user = create(:user, confirmed_at: nil)
    # Attempt to sign in the unconfirmed user
    sign_in(user)
    expect(page).to have_current_path(root_path)
    # A flash warning is displayed informing the user that they have to confirm their email
    within('#notification-area') do
      # Click the link embedded in the flash message
      find('a.a-orange').click
    end
    # The user is redirected to the confirmation page
    expect(current_path).to eq(new_user_confirmation_path)
  end

  private

  # rubocop:disable Metrics/AbcSize
  def expectations_for_unconfirmed_user_with_no_confirmation_token_after_sign_in_attempt(user)
    # The user is not signed in
    expect(page).to have_current_path(root_path)
    # A flash notice is displayed informing the user that a confirmation email has been sent
    expect(page).to have_selector('#notification-area',
                                  text: I18n.t('devise.registrations.signed_up_but_unconfirmed'))
    # reload the user to check confirmation values
    user.reload
    # The user remains unconfirmed
    expect(user.confirmed?).to be(false)
    # A confirmation_token now exists
    expect(user.confirmation_token).to be_present
  end
  # rubocop:enable Metrics/AbcSize

  def expectations_for_unconfirmed_user_with_confirmation_token_after_sign_in_attempt
    # The user is not signed in
    expect(current_path).to eq(root_path)
    within('#notification-area') do
      # Get the HTML content of the flash message
      html_content = find(:xpath, '.').native.attribute('innerHTML')
      # A flash warning is displayed informing the user that they have to confirm their email
      expect(html_content).to include(I18n.t('devise.failure.unconfirmed'))
    end
  end
end
