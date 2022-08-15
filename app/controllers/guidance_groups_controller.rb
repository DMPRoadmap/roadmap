# frozen_string_literal: true

# Controller for the Guidances page that handles Group info
class GuidanceGroupsController < ApplicationController
  after_action :verify_authorized
  respond_to :html

  # TODO: We should really update this to be RESTful and move it either
  #       into the `org_admin` namespace or a new `admin` namespace.
  #
  #       Publish and Unpublish actions should be consolidated with :update
  #       after conversion to RESTful actions

  # GET /org/admin/guidancegroup/:id/admin_new
  def admin_new
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
    @guidance_group = GuidanceGroup.new(org_id: current_user.org.id)
    authorize @guidance_group
  end

  # POST /org/admin/guidancegroup/:id/admin_create
  # rubocop:disable Metrics/AbcSize
  def admin_create
    # Ensure that the user can only create GuidanceGroups for their Org
    args = guidance_group_params.to_h.merge({ org_id: current_user.org.id })
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
    @guidance_group = GuidanceGroup.new(args)
    authorize @guidance_group

    if @guidance_group.save
      flash.now[:notice] = success_message(@guidance_group, _('created'))
      render :admin_edit
    else
      flash.now[:alert] = failure_message(@guidance_group, _('create'))
      render :admin_new
    end
  end
  # rubocop:enable Metrics/AbcSize

  # GET /org/admin/guidancegroup/:id/admin_edit
  def admin_edit
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
  end

  # PUT /org/admin/guidancegroup/:id/admin_update
  # rubocop:disable Metrics/AbcSize
  def admin_update
    @guidance_groups = GuidanceGroup.where(org_id: current_user.org.id)
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group

    if @guidance_group.update(guidance_group_params)
      flash.now[:notice] = success_message(@guidance_group, _('saved'))
    else
      flash.now[:alert] = failure_message(@guidance_group, _('save'))
    end
    render :admin_edit
  end
  # rubocop:enable Metrics/AbcSize

  # PUT /org/admin/guidancegroup/:id/admin_update_publish
  def admin_update_publish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group

    if @guidance_group.update(published: true)
      flash[:notice] = _('Your guidance group has been published and is now available to users.')

    else
      flash[:alert] = failure_message(@guidance_group, _('publish'))
    end
    redirect_to admin_index_guidance_path
  end

  # PUT /org/admin/guidancegroup/:id/admin_update_unpublish
  def admin_update_unpublish
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group

    if @guidance_group.update(published: false)
      flash[:notice] = _('Your guidance group is no longer published and will not be available to users.')
    else
      flash[:alert] = failure_message(@guidance_group, _('unpublish'))
    end
    redirect_to admin_index_guidance_path
  end

  # DELETE /org/admin/guidancegroup/:id/admin_destroy
  def admin_destroy
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    if @guidance_group.destroy
      flash[:notice] = success_message(@guidance_group, _('deleted'))
    else
      flash[:alert] = failure_message(@guidance_group, _('delete'))
    end
    redirect_to admin_index_guidance_path
  end

  private

  def guidance_group_params
    params.require(:guidance_group).permit(:org_id, :name, :published, :optional_subset)
  end
end
