class GuidancesController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  ##
  # GET /guidances
  def admin_index
    authorize Guidance
    @guidances = policy_scope(Guidance)
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id)
  end

  ##
  # GET /guidances/1
  def admin_show
    @guidance = Guidance.eager_load(:guidance_group, :themes).find(params[:id])
    authorize @guidance
  end

  def admin_new
    @guidance = Guidance.new
    authorize @guidance
    @themes = Theme.all.order('title')
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id).order('name ASC')
	end

  ##
  # GET /guidances/1/edit
  def admin_edit
    @guidance = Guidance.eager_load(:themes, :guidance_group).find(params[:id])
    authorize @guidance
    @themes = Theme.all.order('title')
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id).order('name ASC')
  end

  ##
  # POST /guidances
  def admin_create
    @guidance = Guidance.new(guidance_params)
    authorize @guidance
    @guidance.text = params["guidance-text"]

    @guidance.themes = []
    if !guidance_params[:theme_ids].nil?
      guidance_params[:theme_ids].map{|t| @guidance.themes << Theme.find(t.to_i) unless t.empty? }
    end

    if @guidance.save
      redirect_to admin_show_guidance_path(@guidance), notice: _('Guidance was successfully created.')
    else
      flash[:notice] = failed_create_error(@guidance, _('guidance'))
      @themes = Theme.all.order('title')
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id).order('name ASC')
      render action: "admin_new"
    end
  end

  ##
  # PUT /guidances/1
  def admin_update
 		@guidance = Guidance.find(params[:id])
    authorize @guidance
		@guidance.text = params["guidance-text"]
    if @guidance.update_attributes(guidance_params)
      redirect_to admin_show_guidance_path(params[:guidance]), notice: _('Guidance was successfully updated.')
    else
      flash[:notice] = failed_update_error(@guidance, _('guidance'))
      @themes = Theme.all.order('title')
      @guidance_groups = GuidanceGroup.where(org_id: current_user.org_id).order('name ASC')

      render action: "admin_edit"
    end
  end

  ##
  # DELETE /guidances/1
  def admin_destroy
   	@guidance = Guidance.find(params[:id])
    authorize @guidance
    if @guidance.destroy
      redirect_to admin_index_guidance_path, notice: _('Guidance was successfully deleted.')
    else
      redirect_to admin_index_guidance_path, notice: failed_destroy_error(@guidance, _('guidance'))
    end
	end


  private
    def guidance_params
      # The form on the page is weird. The text and template/section/question stuff is outside of the normal form params
      params.require(:guidance).permit(:guidance_group_id, :published, theme_ids: [])
    end
end