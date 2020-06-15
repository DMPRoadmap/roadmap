# frozen_string_literal: true

class SessionsController < Devise::SessionsController

  def new
    redirect_to(root_path)
  end

  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  def create
    existing_user = User.find_by(email: params[:user][:email])
    if !existing_user.nil?

      # Until ORCID login is supported
      if !session["devise.shibboleth_data"].nil?
        args = {
          identifier_scheme: IdentifierScheme.find_by(name: "shibboleth"),
          value: session["devise.shibboleth_data"]["uid"],
          identifiable: existing_user,
          attrs: session["devise.shibboleth_data"]
        }
        @ui = Identifier.new(args)
      end
      unless existing_user.get_locale.nil?
        session[:locale] = existing_user.get_locale
      end
      # Method defined at controllers/application_controller.rb
      set_gettext_locale
    end

    super do
      if !@ui.nil? && @ui.save
        # rubocop:disable Metrics/LineLength
        flash[:notice] = _("Your account has been successfully linked to your institutional credentials. You will now be able to sign in with them.")
        # rubocop:enable Metrics/LineLength
      end
    end
  end

  def destroy
    super
    session[:locale] = nil
    # Method defined at controllers/application_controller.rb
    set_gettext_locale
  end

end
