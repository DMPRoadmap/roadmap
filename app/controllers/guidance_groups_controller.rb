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
      redirect_to admin_index_guidance_path, notice: _('Guidance group was successfully created.')
    else
      render action: "new"
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
      redirect_to admin_index_guidance_path(params[:guidance_group]), notice: _('Guidance group was successfully updated.')
    else
      render action: "edit"
    end
  end


  # PUT /guidance_groups/1
  def admin_update_publish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org.id = current_user.org.id
    @guidance_group.published = true

    if @guidance_group.update_attributes(params[:guidance_group])
      redirect_to admin_index_guidance_path(params[:guidance_group]), notice: _('Guidance group was successfully updated.')
    else
      render action: "edit"
    end
  end


  # DELETE /guidance_groups/1
  # DELETE /guidance_groups/1.json
  def admin_destroy
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.destroy

    redirect_to admin_index_guidance_path, notice: _('Guidance group was successfully deleted.')
  end

end