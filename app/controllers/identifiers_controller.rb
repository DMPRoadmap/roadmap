# frozen_string_literal: true

# Controller that handles a user disassociating their Shib or ORCID on the profile page
class IdentifiersController < ApplicationController
  respond_to :html
  after_action :verify_authorized

  # DELETE /users/identifiers
  # rubocop:disable Metrics/AbcSize
  def destroy
    authorize Identifier
    user = User.find(current_user.id)
    identifier = Identifier.find(params[:id])

    # If the requested identifier belongs to the current user remove it
    if user.identifiers.include?(identifier)
      identifier.destroy!
      flash.now[:notice] =
        format(_('Successfully unlinked your account from %{is}.'), is: identifier.identifier_scheme&.description)
    else
      flash.now[:alert] =
        format(_('Unable to unlink your account from %{is}.'), is: identifier.identifier_scheme&.description)
    end

    # TODO: While this works for ORCID it might not for future integrations. We should consider
    #       moving it to a different place on the Edit Profile page
    # Revoke any OAuth access tokens for the identifier
    tokens = user.external_api_access_tokens.select do |token|
      token.external_service_name == identifier.identifier_scheme.name.downcase
    end
    tokens.each(&:revoke!)

    redirect_to users_third_party_apps_path
  end
  # rubocop:enable Metrics/AbcSize
end
