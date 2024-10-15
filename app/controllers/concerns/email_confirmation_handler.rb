module EmailConfirmationHandler
  extend ActiveSupport::Concern

  def handle_confirmation_instructions(user)
    user.send_confirmation_instructions
    flash[:notice] = I18n.t('devise.registrations.signed_up_but_unconfirmed')
    redirect_to root_path
  end
end
