# frozen_string_literal: true

# EmailConfirmationHandler

# Some users in our db are both unconfirmed AND have no outstanding confirmation_token
# This is true for those users due to the following:
#   - We haven't always used Devise's :confirmable module (it generates a confirmation_token when a user is created)
#   - We have set `confirmed_at` and `confirmation_token` to nil via Rake tasks
# This concern is meant to improve the confirmation process for those users
module EmailConfirmationHandler
  extend ActiveSupport::Concern

  def confirmation_instructions_missing_and_handled?(user)
    #  A user's "confirmation instructions are missing" if they're both unconfirmed and have no confirmation_token
    return false if user_confirmed_or_has_confirmation_token?(user)

    handle_missing_confirmation_instructions(user)
    true
  end

  private

  def user_confirmed_or_has_confirmation_token?(user)
    user.confirmed? || user.confirmation_token.present?
  end

  def handle_missing_confirmation_instructions(user)
    user.send_confirmation_instructions
    redirect_to root_path, notice: I18n.t('devise.registrations.signed_up_but_unconfirmed')
  end
end
