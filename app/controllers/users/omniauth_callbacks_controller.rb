# frozen_string_literal: true

module Users
  # Overrides to Devise Omniauth controller
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
    skip_before_action :verify_authenticity_token, only: %i[orcid shibboleth]

    # You should also create an action method in this controller like this:
    # def twitter
    # end

    #
    # GET|POST /users/auth/shibboleth
    def passthru
      org = Org.find_by(id: shibboleth_passthru_params[:org_id])

p "JUST PASSIN THROUGH: #{org&.name}"

      if org.present?
        entity_id = org.identifier_for_scheme(scheme: 'shibboleth')

p "USING: #{entity_id&.value}"

        if entity_id.present?
          shib_login = Rails.configuration.x.shibboleth.login_url
          url = "#{request.base_url.gsub('http:', 'https:')}#{shib_login}"
          target = user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')
          # initiate shibboleth login sequence
          redirect_to "#{url}?target=#{target}&entityID=#{entity_id.value}"
        else
          redirect_to root_path, alert: _('Unable to connect to your institution\'s server!')
        end
      else
        redirect_to root_path, alert: _('Unable to connect to your institution\'s server!')
      end

      # super
    end

    def failure
      p 'FAILURE!'
      p failed_strategy.name
      pp resource&.inspect
    end

    # Shibboleth callback (the action invoked after the user signs in)
    #
    # GET|POST /users/auth/shibboleth/callback
    # rubocop:disable Metrics/AbcSize
    def shibboleth
      p 'CALLBACK!'

      # TODO: If they already had an account auto merge/link the eppn to the existing account

      @user = User.from_omniauth(request.env['omniauth.auth'])

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
    # def after_omniauth_failure_path_for(scope)
    #   super(scope)
    # end

    private

    def shibboleth_passthru_params
      params.require(:user).permit(:org_id)
    end
  end
end
