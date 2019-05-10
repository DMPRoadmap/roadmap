# frozen_string_literal
class Zenodo::PlanUploadsController < Zenodo::BaseController

  include OAuthable

  def create
    @plan = current_user.plans.find(params[:plan_id])
    if @plan.zenodo_id?
      redirect_to share_plan_url(@plan),
                  notice: "Plan already uploaded to Zenodo (id: #{@plan.zenodo_id})"
      return
    end
    if current_user.zenodo_access_token?
      ZenodoUploadService.new(plan: @plan, user: current_user).call
      redirect_to share_plan_url(@plan), notice: "Upload to Zenodo was successful"
    else
      redirect_to authorize_oauth2_url(provider: "zenodo")
    end
  end

  private

  def client
    @client ||= client_for_oauth2_provider("zenodo")
  end

end
