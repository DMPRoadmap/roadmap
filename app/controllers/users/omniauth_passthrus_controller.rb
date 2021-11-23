# frozen_string_literal: true

module Users
  # Handlers for Omniauth Passthru methods
  class OmniauthPassthrusController < ApplicationController
    # POST /users/auth/shibboleth
    def shibboleth_passthru
      skip_authorization

      org = ::Org.find_by(id: shibboleth_passthru_params[:org_id])
      if org.present?
        session['omniauth-org'] = encrypt(value: org.id)
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

    private

    def shibboleth_passthru_params
      params.require(:user).permit(:org_id)
    end
  end
end