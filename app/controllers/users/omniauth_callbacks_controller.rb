# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: %i[orcid shibboleth]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  #
  # GET|POST /users/auth/shibboleth
  def passthru

p "PASSTHRU!"

    super

  end

  def failure

p "FAILURE!"
p failed_strategy.name
pp resource&.inspect

  end

  # Shibboleth callback (the action invoked after the user signs in)
  #
  # GET|POST /users/auth/shibboleth/callback
  def shibboleth

p "CALLBACK!"

    # TODO: If they already had an account auto merge/link the eppn to the existing account

    @user = User.from_omniauth(request.env["omniauth.auth"])

pp @user.inspect

    if @user.persisted?

      # TODO: If this is a new user then direct them to the profile page and ask them to
      # finish setting up their account. Once they save that redirect to the Dashboard

      # this will throw if @user is not activated
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Institutional sign in") if is_navigational_format?
    else
      # Removing extra as it can overflow some session stores
      session["devise.shibboleth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url
    end
  end

  # ORCID callback (the action invoked after the user signs in)
  #
  # GET|POST /users/auth/orcid/callback
  def orcid

  end

  protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

end
