# frozen_string_literal: true

# Helper methods for the Sign in / Sign up pages
module AuthenticationHelper
  # Fetches the API client info from the session or the Doorkeeper pre_auth variable depending
  # on which step of the sign in workflow we are on. If we have the Doorkeeper pre_auth then
  # it will also stash the info into the session.
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def process_oauth
    if @pre_auth.present?
      # Ditch any existing session info because this is a new OAuth attempt
      session.delete('oauth-referer')

      oauth_path = oauth_authorization_path(client_id: @pre_auth.client.uid,
                                            redirect_uri: @pre_auth.redirect_uri,
                                            state: @pre_auth.state,
                                            response_type: @pre_auth.response_type,
                                            scope: @pre_auth.scope,
                                            code_challenge: @pre_auth.code_challenge,
                                            code_challenge_method: @pre_auth.code_challenge_method)

      # Fetch the ApiClient because the Doorkeeper OAuthApplication parent class doesn't
      # have the full name
      client = ApiClient.where(uid: @pre_auth.client.uid).first

      # Stash the info into a session variable so that the info is retained accross the sign in
      # workflow
      session['oauth-referer'] = ApplicationService.encrypt(payload: { client_id: client.id,
                                                                       path: oauth_path })

      { path: oauth_path, client: client }

    elsif session['oauth-referer'].present?
      begin
        # Fetch the oauth info from the session and decrypt it
        oauth_hash = ApplicationService.decrypt(payload: session['oauth-referer'])

Rails.logger.warn "OAUTH HASH: #{oauth_hash.inspect}"

        {
          path: oauth_hash['path'],
          client: ApiClient.find_by(id: oauth_hash['client_id'])
        }
      rescue StandardError => e
        Rails.logger.error _("AuthenticationHelper.process_oauth - #{e.message}")
        Rails.logger.error oauth_hash.inspect
        {}
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
end
