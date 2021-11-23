# frozen_string_literal: true

module Users
  # Overrides to Devise Omniauth controller
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
    skip_before_action :verify_authenticity_token, only: %i[orcid shibboleth]


    def failure
p "FAILURE! #{failed_strategy.name}"
    end

    # Shibboleth callback (the action invoked after the user signs in)
    #
    # GET|POST /users/auth/shibboleth/callback
    # rubocop:disable Metrics/AbcSize
    def shibboleth
      # TODO: If they already had an account auto merge/link the eppn to the existing account

p 'CALLBACK!'
pp omniauth_from_request

      @user = User.from_omniauth(
        scheme_name: 'shibboleth', omniauth_hash: omniauth_from_request
      )

pp @user.inspect

      if @user.persisted?

        # TODO: If this is a new user then direct them to the profile page and ask them to
        # finish setting up their account. Once they save that redirect to the Dashboard

        # this will throw if @user is not activated
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: 'Institutional sign in') if is_navigational_format?
      else
        # Removing extra as it can overflow some session stores
        session['devise.shibboleth_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url
      end
    end
    # rubocop:enable Metrics/AbcSize

    # ORCID callback (the action invoked after the user signs in)
    #
    # GET|POST /users/auth/orcid/callback
    def orcid; end

    # The path used when OmniAuth fails
    def after_omniauth_failure_path_for(scope)
    #   super(scope)
      redirect_to root_path, alert: _('We are having trouble communicating with your institution at this time.')
    end

    private

    # Extract the omniauth info from the request
    def omniauth_from_request

Rails.logger.debug "REQUEST ENV: #{request.env.inspect}"

      return {} unless request.env.present?

p '----------------------------------'
pp request.env['omniauth.auth']

      hash = request.env['omniauth.auth']
      hash = request.env[:'omniauth.auth'] unless hash.present?
      hash = hash.present? ? hash : request.env
      hash.hash_with_indifferent_access
    end
  end
end
