# frozen_string_literal: true

require 'rails_helper'

# For testing the custom email confirmation UX flow
# (See `app/controllers/concerns/email_confirmation_handler.rb`)
# Here, we define "unconfirmable" as a user that is both unconfirmed and has no outstanding confirmation token
RSpec.describe 'Email Confirmation', type: :feature do
  scenario 'A user attempts to sign in via the "Sign In" button. However, they are unconfirmable.', :js do
    user = create(:user, :unconfirmable)
    sign_in(user)

    # A flash notice is displayed informing the user that a confirmation email has been sent
    expect(page.text).to have_text(I18n.t('devise.registrations.signed_up_but_unconfirmed'))
    # reload the user to check confirmation values
    user.reload

    # The user remains unconfirmed
    expect(user.confirmed?).to be(false)
    # A confirmation_token now exists
    expect(user.confirmation_token).to be_present
    # The user is not signed in
    expect(current_path).to eq(root_path)

    sign_in(user)
    # A flash warning is displayed informing the user that they have to confirm their email
    expect(page.text).to have_text(I18n.t('devise.failure.unconfirmed'))
  end
end
