# frozen_string_literal: true

module Dmptool
  # DMPTool specific helpers that ensure we bypass the standard Shibboleth federated
  # discovery service and instead send the user directly to their institution's IdP
  # using the Shibbeoleth entityID stored in the identifiers table for the Org
  module Shibbolethable
    # GET|POST /users/auth/shibboleth
    def shibboleth_passthru
      skip_authorization

      org = ::Org.find_by(id: shibboleth_passthru_params[:org_id])
      if org.present?
        entity_id = org.identifier_for_scheme(scheme: 'shibboleth')
        if entity_id.present?
          shib_login = Rails.configuration.x.shibboleth.login_url
          target = user_shibboleth_omniauth_callback_url.gsub('http:', 'https:')
          # initiate shibboleth login sequence
          redirect_to "#{shib_login}?target=#{target}&entityID=#{entity_id.value}"
        else
          redirect_to root_path, alert: _('Unable to connect to your institution\'s server!')
        end
      else
        redirect_to root_path, alert: _('Unable to connect to your institution\'s server!')
      end
    end

    # Shibboleth callback (the action invoked after the user signs in)
    #
    # GET|POST /users/auth/shibboleth/callback
    # rubocop:disable Metrics/AbcSize
    def shibboleth
      p 'CALLBACK!'

      # TODO: If they already had an account auto merge/link the eppn to the existing account

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

    def shibboleth_passthru_params
      params.require(:user).permit(:org_id)
    end

    # Extract the omniauth info from the request
    def omniauth_from_request

  pp request.env

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
end
