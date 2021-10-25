# frozen_string_literal: true

## TODO verify functionality after merging
## Specifically, set_gettext_locale
# class SessionsController < Devise::SessionsController

#   def new
#     redirect_to(root_path)
#   end

#   # Capture the user's shibboleth id if they're coming in from an IDP
#   # ---------------------------------------------------------------------
#   def create
#     existing_user = User.find_by(email: params[:user][:email])
#     if !existing_user.nil?

#       # Until ORCID login is supported
#       if !session["devise.shibboleth_data"].nil?
#         args = {
#           identifier_scheme: IdentifierScheme.find_by(name: "shibboleth"),
#           identifier: session["devise.shibboleth_data"]["uid"],
#           user: existing_user
#         }
#         if UserIdentifier.create(args)
#           # rubocop:disable Metrics/LineLength
#           success = _("Your account has been successfully linked to your institutional credentials. You will now be able to sign in with them.")
#           # rubocop:enable Metrics/LineLength
#         end
#       end
#       if session[:locale].blank? && existing_user.get_locale.present?
#         session[:locale] = existing_user.get_locale
#       end
#       # Method defined at controllers/application_controller.rb
#       set_gettext_locale
#     end
#     super
#     if success
#       flash[:notice] = success
#     end
#   end

#   def destroy
#     # We want to keep the user selected language even after the user logs out
#     session_locale = session[:locale]
#     super
#     session[:locale] = session_locale
#     # Method defined at controllers/application_controller.rb
#     set_gettext_locale
#   end

# end
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
    session_locale = session[:locale]
    super
    # We want to keep the locale even after the user logs out. This way we will
    # not keep a default language
    session[:locale] = session_locale
    # Method defined at controllers/application_controller.rb
    set_locale
  end

end
