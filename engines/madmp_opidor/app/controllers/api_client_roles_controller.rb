# frozen_string_literal: true

# Controller that handles adding/updating/removing collaborators from a plan
class ApiClientRolesController < ApplicationController
  respond_to :html

  after_action :verify_authorized

  # POST /roles
  # rubocop:disable Metrics/AbcSize
  def create
    @client_role = ApiClientRole.new(client_role_params)
    authorize @client_role
    if client_role_params[:api_client_id].present?
      api_client = ApiClient.find(client_role_params[:api_client_id])
      @client_role.api_client = api_client
      if ApiClientRole.exists?(plan: @client_role.plan, api_client:)

        flash[:notice] = format(_('Plan is already shared with %{api_client}.'),
                                api_client: api_client.name)
      elsif @client_role.save
        flash[:notice] = format(_('Plan shared with "%{api_client}" application successfully.'),
                                api_client: api_client.name)
      else
        flash[:alert] = format(_('An error has occured while sharing the plan with "%{api_client}".'),
                               api_client: api_client.name)
      end
    else
      flash[:alert] = _('Please select an application in the list')
    end
    redirect_to controller: 'plans', action: 'share', id: @client_role.plan.id
  end
  # rubocop:enable Metrics/AbcSize

  # PUT /roles/:id
  def update
    @client_role = ApiClientRole.find(params[:id])
    authorize @client_role

    if @client_role.update(access: client_role_params[:access])
      render json: {
        code: 1,
        msg: format(_('Successfully changed the permissions for %{api_client}.'),
                    api_client: @client_role.api_client.name)
      }
    else
      render json: { code: 0, msg: flash[:alert] }
    end
  end

  def destroy
    @client_role = ApiClientRole.find(params[:id])
    authorize @client_role
    @client_role.destroy
    flash[:notice] = _('Access removed')
    redirect_to controller: 'plans', action: 'share', id: @client_role.plan.id
  end

  private

  def client_role_params
    params.require(:api_client_role).permit(:plan_id, :access, :api_client_id)
  end
end
