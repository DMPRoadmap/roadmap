# frozen_string_literal: true

# Controller that handles user login and logout
class SessionsController < Devise::SessionsController
  def new
    redirect_to(root_path)
  end

  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  # rubocop:disable Metrics/AbcSize
  def create
    existing_user = User.find_by(email: params[:user][:email])
    if existing_user.present?

      unless existing_user.confirmed_or_has_confirmation_token?
        handle_missing_confirmation_instructions(existing_user)
        return
      end

      # Until ORCID login is supported
      @ui = create_shibboleth_identifier(existing_user) unless session['devise.shibboleth_data'].nil?
      session[:locale] = existing_user.locale unless existing_user.locale.nil?
      # Method defined at controllers/application_controller.rb
      set_locale
    end

    super do
      if !@ui.nil? && @ui.save
        flash[:notice] = _('Your account has been successfully linked to your institutional credentials. ' \
                           'You will now be able to sign in with them.')
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  def destroy
    super
    session[:locale] = nil
    # Method defined at controllers/application_controller.rb
    set_locale
  end
end

private

def create_shibboleth_identifier(user)
  args = {
    identifier_scheme: IdentifierScheme.find_by(name: 'shibboleth'),
    value: session['devise.shibboleth_data']['uid'],
    identifiable: user,
    attrs: session['devise.shibboleth_data']
  }
  Identifier.new(args)
end

def handle_missing_confirmation_instructions(user)
  # Generate a confirmation_token and email confirmation instructions to the user
  user.send_confirmation_instructions
  # Notify the user they are unconfirmed but confirmation instructions have been sent
  flash[:notice] = I18n.t('devise.registrations.signed_up_but_unconfirmed')
  redirect_to root_path
end
