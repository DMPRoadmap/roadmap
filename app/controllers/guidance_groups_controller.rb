# frozen_string_literal: true

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
    @guidance_group = GuidanceGroup.new(guidance_group_params)
    authorize @guidance_group
    @guidance_group.org_id = current_user.org_id
    if params[:save_publish]
      @guidance_group.published = true
    end

    if @guidance_group.save
      flash.now[:notice] = success_message(@guidance_group, _("created"))
      render :admin_edit
    else
      flash.now[:alert] = failure_message(@guidance_group, _("create"))
      render :admin_new
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

    if @guidance_group.update(guidance_group_params)
      flash.now[:notice] = success_message(@guidance_group, _("saved"))
      render :admin_edit
    else
      flash.now[:alert] = failure_message(@guidance_group, _("save"))
      render :admin_edit
    end
  end

  # PUT /guidance_groups/1
  def admin_update_publish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org.id = current_user.org.id
    @guidance_group.published = true

    if @guidance_group.save
      # rubocop:disable LineLength
      flash[:notice] = _("Your guidance group has been published and is now available to users.")
      # rubocop:enable LineLength
    else
      flash[:alert] = failure_message(@guidance_group, _("publish"))
    end
    redirect_to admin_index_guidance_path
  end

  # PUT /guidance_groups/1
  def admin_update_unpublish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.org.id = current_user.org.id
    @guidance_group.published = false

    if @guidance_group.save
      # rubocop:disable LineLength
      flash[:notice] = _("Your guidance group is no longer published and will not be available to users.")
      # rubocop:enable LineLength
    else
      flash[:alert] = failure_message(@guidance_group, _("unpublish"))
    end
    redirect_to admin_index_guidance_path
  end

  # DELETE /guidance_groups/1
  # DELETE /guidance_groups/1.json
  def admin_destroy
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    if @guidance_group.destroy
      flash[:notice] = success_message(@guidance_group, _("deleted"))
    else
      flash[:alert] = failure_message(@guidance_group, _("delete"))
    end
    redirect_to admin_index_guidance_path
  end

  private

  def guidance_group_params
    params.require(:guidance_group)
          .permit(:org_id, :name, :optional_subset, :published, :org, :guidances)
  end

end
