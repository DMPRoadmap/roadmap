# frozen_string_literal: true

module SuperAdmin

  class ApiClientsController < ApplicationController

    respond_to :html

    include OrgSelectable

    helper PaginableHelper

    # GET /api_clients
    def index
      authorize(ApiClient)
      @api_clients = ApiClient.all.page(1)
    end

    # GET /api_clients/new
    def new
      authorize(ApiClient)
      @api_client = ApiClient.new
    end

    # GET /api_clients/1/edit
    def edit
      @api_client = ApiClient.find(params[:id])
      authorize(@api_client)
    end

    # POST /api_clients
    def create
      authorize(ApiClient)

      # Translate the Org selection
      org = org_from_params(params_in: api_client_params, allow_create: false)
      attrs = remove_org_selection_params(params_in: api_client_params)

      @api_client = ApiClient.new(attrs)
      @api_client.org = org if org.present?

      if @api_client.save
        UserMailer.api_credentials(@api_client).deliver_now()
        msg = success_message(@api_client, _("created"))
        msg += _(". The API credentials have been emailed to %{email}") % { email: @api_client.contact_email }
        flash.now[:notice] = msg
        render :edit
      else
        flash.now[:alert] = failure_message(@api_client, _("create"))
        render :new
      end
    end

    # PATCH/PUT /api_clients/:id
    def update
      @api_client = ApiClient.find(params[:id])
      authorize(@api_client)

      # Translate the Org selection
      org = org_from_params(params_in: api_client_params, allow_create: false)

p org.inspect

      @api_client.org = org
      attrs = remove_org_selection_params(params_in: api_client_params)

p attrs.inspect

      if @api_client.update(attrs)
        flash.now[:notice] = success_message(@api_client, _("updated"))
      else
        flash.now[:alert] = failure_message(@api_client, _("update"))
      end
      render :edit
    end

    # DELETE /api_clients/:id
    def destroy
      api_client = ApiClient.find(params[:id])
      authorize(api_client)
      if api_client.destroy
        msg = success_message(api_client, _("deleted"))
        redirect_to super_admin_api_clients_path, notice: msg
      else
        flash.now[:alert] = failure_message(api_client, _("delete"))
        render :edit
      end
    end

    # GET /api_clients/:id/refresh_credentials/
    def refresh_credentials
      @api_client = ApiClient.find(params[:id])
      if @api_client.present?
        @api_client.generate_credentials
        @api_client.save
      end
    end

    # GET /api_clients/:id/email_credentials/
    def email_credentials
      @api_client = ApiClient.find(params[:id])
      UserMailer.api_credentials(@api_client).deliver_now() if @api_client.present?
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def api_client_params
      params.require(:api_client).permit(:name, :description, :homepage,
                                         :contact_name, :contact_email,
                                         :client_id, :client_secret,
                                         :org_id, :org_name, :org_sources, :org_crosswalk)
    end

  end

end
