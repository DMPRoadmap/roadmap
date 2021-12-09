# frozen_string_literal: true

module Dmptool
  # Extensions to the core DMPRoadmap UsersController
  module UsersController
    # DELETE /users/:user_id/oauth_credential_tokens/:id
    # rubocop:disable Metrics/AbcSize
    def revoke_oauth_access_token
      user = User.includes(:access_tokens).find_by(id: params[:user_id])
      authorize user
      token = Doorkeeper::AccessToken.find_by(id: params[:id])
      if token.present?
        token.update(revoked_at: Time.now)
        redirect_to users_third_party_apps_path,
                    notice: _('The application is no longer authorized to access your data.')
      else
        redirect_to users_third_party_apps_path, alert: _('Unable to revoke the authorized application.')
      end
    end
    # rubocop:enable Metrics/AbcSize

    # GET /users/third_party_apps
    def third_party_apps
      # Displays the user's 3rd party applications profile page
      authorize ::User

      @identifier_schemes = IdentifierScheme.for_users.order(:name)
      @tokens = current_user.access_tokens.select { |token| token.revoked_at.nil? }
    end

    # GET /users/developer_tools
    def developer_tools
      # Displays the user's developer tools profile page
      authorize ::User

      @api_client = ApiClient.find_or_initialize_by(user_id: current_user.id)
      @api_client.contact_name = current_user.name(false) unless @api_client.contact_name.present?
      @api_client.contact_email = current_user.email unless @api_client.contact_email.present?
    end
  end
end
