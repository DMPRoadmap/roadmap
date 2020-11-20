# frozen_string_literal: true

class SessionsController < Devise::SessionsController

  def new
    redirect_to(root_path)
  end

  # Capture the user's shibboleth id if they're coming in from an IDP
  # ---------------------------------------------------------------------
  # rubocop:disable Metrics/AbcSize
  def create
    existing_user = User.find_by(email: params[:user][:email])
    unless existing_user.nil?

      # Until ORCID login is supported
      unless session["devise.shibboleth_data"].nil?
        args = {
          identifier_scheme: IdentifierScheme.find_by(name: "shibboleth"),
          value: session["devise.shibboleth_data"]["uid"],
          identifiable: existing_user,
          attrs: session["devise.shibboleth_data"]
        }
        @ui = Identifier.new(args)
      end
      session[:locale] = existing_user.locale unless existing_user.locale.nil?
      # Method defined at controllers/application_controller.rb
      set_locale
    end

    super do
      if !@ui.nil? && @ui.save
        # rubocop:disable Layout/LineLength
        flash[:notice] = _("Your account has been successfully linked to your institutional credentials. You will now be able to sign in with them.")
        # rubocop:enable Layout/LineLength
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
