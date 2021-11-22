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

    def shibboleth_passthru_params
      params.require(:user).permit(:org_id)
    end
  end
end
