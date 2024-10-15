# frozen_string_literal: true

# EmailConfirmationHandler

# Some users in our db are both unconfirmed AND have no outstanding confirmation_token
# This is true for those users due to the following:
#   - We haven't always used Devise's :confirmable module (it generates a confirmation_token when a user is created)
#   - We have set `confirmed_at` and `confirmation_token` to nil via Rake tasks
# This concern is meant to improve the confirmation process for those users
module EmailConfirmationHandler
  extend ActiveSupport::Concern

  # confirmation instructions are "missing" if the user is both unconfirmed AND has no outstanding confirmation_token
  def missing_confirmation_instructions_handled?(user)
    return false if user.confirmed_or_has_confirmation_token?

    handle_missing_confirmation_instructions(user)
    true
  end

  private

  def handle_missing_confirmation_instructions(user)
    user.send_confirmation_instructions
    redirect_to root_path, notice: I18n.t('devise.registrations.signed_up_but_unconfirmed')
  end
end
