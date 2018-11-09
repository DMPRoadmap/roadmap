# frozen_string_literal: true

module Dmptool

  class SessionsController < Devise::SessionsController

    def new
      redirect_to(root_path)
    end

    # Capture the user's shibboleth id if they're coming in from an IDP
    # ---------------------------------------------------------------------
    def create
      existing_user = User.find_by(email: params[:user][:email])
      if !existing_user.nil?
        # Ldap Users password reset
        unless existing_user.encrypted_password.present?
          existing_user.valid_password?(params[:user][:password])
        end

        unless existing_user.get_locale.nil?
          session[:locale] = existing_user.get_locale
        end
        # Method defined at controllers/application_controller.rb
        set_gettext_locale
      end
      super
    end

    def destroy
      super
      session[:locale] = nil
      # Method defined at controllers/application_controller.rb
      set_gettext_locale
    end

  end

end
