# frozen_string_literal: true

class ApiClientsController < ApplicationController

  respond_to :html

  # POST /api_clients
  def create
    attrs = api_client_params
    # If this is a regular user signing up, just use their email as the api_client.name
    attrs[:name] = attrs[:contact_email] unless attrs[:name].present?
    @api_client = ApiClient.new(attrs)

    # Allow all available scopes by default
    attrs[:scopes] = @api_client.available_scopes
    @api_client.org = current_user.org if current_user.org.present?

    authorize(@api_client)
    if @api_client.save
      UserMailer.new_api_client(@api_client).deliver_now
      @msg = "API Registration complete. Use your new client_id and client_secret to access the API."
    else
      @msg = "Unable to register for the API - #{@api_client.errors.full_messages.join(', ')}"
    end
    render "devise/registrations/api_client_save"
  end

  # PATCH/PUT /api_clients/:id
  def update
    @api_client = ApiClient.find(params[:id])
    authorize(@api_client)

    attrs = api_client_params
    attrs[:scopes] = @api_client.available_scopes unless @api_client.scopes.present?

    if @api_client.update(attrs)
      @msg = "API Registration updated"
    else
      @msg = "Unable to update the API registration - #{@api_client.errors.full_messages.join(', ')}"
    end
    render "devise/registrations/api_client_save"
  end

  # GET /api_clients/:id/refresh_credentials/
  def refresh_credentials
    @api_client = ApiClient.find(params[:id])
    return unless @api_client.present?

    authorize(@api_client)
    original = @api_client.client_secret
    @api_client.renew_secret
    @api_client.save
    @success = original != @api_client.client_secret
    render "devise/registrations/api_client_refresh_credentials"
  end

  private

  def api_client_params
    params.require(:api_client).permit(:name, :description, :homepage, :logo, :remove_logo,
                                       :contact_name, :contact_email,
                                       :client_id, :client_secret,
                                       :user_id, :org_id, :redirect_uri, :callback_uri)
  end

end
