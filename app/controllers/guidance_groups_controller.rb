class GuidanceGroupsController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  # GET /guidance_groups/1
  def admin_show
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
  end


  # GET add new guidance groups
  def admin_new
    @guidance_group = GuidanceGroup.new
    authorize @guidance_group
  end


  # POST /guidance_groups
  # POST /guidance_groups.json
  def admin_create
    @guidance_group = GuidanceGroup.new(params[:guidance_group])
    authorize @guidance_group
    @guidance_group.org_id = current_user.org_id
    if params[:save_publish]
      @guidance_group.published = true
    end

    if @guidance_group.save
      redirect_to admin_index_guidance_path, notice: success_message(_('guidance group'), _('created'))
    else
      flash[:alert] = failed_create_error(@guidance_group, _('guidance group'))
      render 'admin_new'
    end
  end


  # GET /guidance_groups/1/edit
  def admin_edit
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
  end


  # PUT /guidance_groups/1
  def admin_update
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org_id = current_user.org_id
    @guidance_group.published = true unless params[:save_publish].nil?

    if @guidance_group.update_attributes(params[:guidance_group])
      redirect_to admin_index_guidance_path(params[:guidance_group]), notice: success_message(_('guidance group'), _('saved'))
    else
      flash[:alert] = failed_update_error(@guidance_group, _('guidance group'))
      render 'admin_edit'
    end
  end

  # PUT /guidance_groups/1
  def admin_update_publish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org.id = current_user.org.id
    @guidance_group.published = true

    @guidance_group.save
    flash[:notice] = _('Your guidance group has been published and is now available to users.')
    redirect_to admin_index_guidance_path
  end

  # PUT /guidance_groups/1
  def admin_update_unpublish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org.id = current_user.org.id
    @guidance_group.published = false

    @guidance_group.save
    flash[:notice] = _('Your guidance group is no longer published and will not be available to users.')
    redirect_to admin_index_guidance_path
  end

  # DELETE /guidance_groups/1
  # DELETE /guidance_groups/1.json
  def admin_destroy
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    if @guidance_group.destroy
      redirect_to admin_index_guidance_path, notice: success_message(_('guidance group'), _('deleted'))
    else
      redirect_to admin_index_guidance_path, alert: failed_destroy_error(@guidance_group, _('guidance group'))
    end
  end

end