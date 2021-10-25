# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: %i[orcid shibboleth]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  #
  # GET|POST /users/auth/shibboleth
  def passthru

p "PASSTHRU"
    super

  end


  # Shibboleth callback (the action invoked after the user signs in)
  #
  # GET|POST /users/auth/shibboleth/callback
  def shibboleth

p "CALLBACK"


    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?

      @

      # this will throw if @user is not activated
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Institutional sign in") if is_navigational_format?
    else
      # Removing extra as it can overflow some session stores
      session["devise.shibboleth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url
    end
  end

  # GET|POST /users/auth/shibboleth/callback
  def failure
    redirect_to root_path
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

end
