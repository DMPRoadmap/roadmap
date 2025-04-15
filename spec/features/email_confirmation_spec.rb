# frozen_string_literal: true

require 'rails_helper'

# For testing the custom email confirmation UX flow
# (See `app/controllers/concerns/email_confirmation_handler.rb`)
# Here, we define "unconfirmable" as a user that is both unconfirmed and has no outstanding confirmation token
RSpec.describe 'Email Confirmation', type: :feature do
  before(:each) do
    @default_locale = I18n.default_locale
    I18n.default_locale = :'en-CA'
  end

  after(:each) do
    I18n.default_locale = @default_locale
  end

  scenario 'A user attempts to sign in via the "Sign In" button. However, they are unconfirmable.', :js do
    # Setup
    user = create(:user, :unconfirmable)

    # Actions
    sign_in(user)
    user.reload

    # Expectations
    expectations_for_unconfirmable_user_after_sign_in_attempt(user)

    # Actions
    sign_in(user)

    # Expectations
    expect_request_new_confirmation_link_message
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

    # Actions
    click_link 'Sign in with institutional or social ID'

    # Expectations
    expect_request_new_confirmation_link_message
  end

  private

  def expectations_for_unconfirmable_user_after_sign_in_attempt(user)
    # The user remains unconfirmed
    expect(user.confirmed?).to be(false)
    # A confirmation_token now exists
    expect(user.confirmation_token).to be_present
    # The user is not signed in
    expect(current_path).to eq(root_path)
    # The correct flash message was rendered
    expect_confirmation_link_has_been_sent_message
  end

  def expect_confirmation_link_has_been_sent_message
    msg = 'A message with a confirmation link has been sent to your email address. ' \
          'Please open the link to activate your account. ' \
          'If you do not receive the confirmation email, please check your spam filter.'
    expect(page.text).to have_text(msg)
  end

  def expect_request_new_confirmation_link_message
    msg = 'You need to confirm your account before continuing. ' \
          '(Click to request a new confirmation email)'
    expect(page.text).to have_text(msg)
  end
end
