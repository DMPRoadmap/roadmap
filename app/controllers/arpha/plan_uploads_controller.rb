class Arpha::PlanUploadsController < Arpha::BaseController

  def create
    @plan = current_user.plans.find(params[:plan_id])
    if @plan.arpha_url?
      redirect_to share_plan_url(@plan),
                  notice: "Plan already uploaded to Arpha (link: #{@plan.arpha_url})"
      return
    end
    if current_user.arpha_api_key?
      @arpha_upload_service = ArphaUploadService.new(plan: @plan, user: current_user)
      @arpha_upload_service.call
      redirect_to @arpha_upload_service.link
    else
      flash[:alert] = _("Please connect your Arpha account before uploading to Arpha.")
      redirect_to share_plan_url(@plan)
    end
  end

end
