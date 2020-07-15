# frozen_string_literal: true

class GuidancesController < ApplicationController

  after_action :verify_authorized
  respond_to :html

  # TODO: We should really update this to be RESTful and move it either
  #       into the `org_admin` namespace or a new `admin` namespace.
  #
  #       Publish and Unpublish actions should be consolidated with :update
  #       after conversion to RESTful actions

  # GET /org/admin/guidance/:id/admin_index
  def admin_index
    authorize Guidance
    @guidances = Guidance.by_org(current_user.org)
                         .includes(:guidance_group, :themes).page(1)
    ensure_default_group(current_user.org)
    @guidance_groups = GuidanceGroup.by_org(current_user.org).page(1)
  end

  # GET /org/admin/guidance/:id/admin_new
  def admin_new
    @guidance = Guidance.new
    authorize @guidance
    render :new_edit
  end

  # GET /org/admin/guidance/:id/admin_edit
  def admin_edit
    @guidance = Guidance.eager_load(:themes, :guidance_group)
                        .find(params[:id])
    authorize @guidance
    render :new_edit
  end

  # POST /org/admin/guidance/:id/admin_create
  def admin_create
    @guidance = Guidance.new(guidance_params)
    authorize @guidance

    if @guidance.save
      if @guidance.published?
        guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
        if !guidance_group.published? || guidance_group.published.nil?
          guidance_group.published = true
          guidance_group.save
        end
      end
      flash.now[:notice] = success_message(@guidance, _("created"))
    else
      flash.now[:alert] = failure_message(@guidance, _("create"))
    end
    render :new_edit
  end

  # PUT /org/admin/guidance/:id/admin_update
  def admin_update
    @guidance = Guidance.find(params[:id])
    authorize @guidance

    if @guidance.update_attributes(guidance_params)
      if @guidance.published?
        guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
        if !guidance_group.published? || guidance_group.published.nil?
          guidance_group.published = true
          guidance_group.save
        end
      end
      flash.now[:notice] = success_message(@guidance, _("saved"))
    else
      flash.now[:alert] = failure_message(@guidance, _("save"))
    end
    render :new_edit
  end

  # DELETE /org/admin/guidance/:id/admin_destroy
  def admin_destroy
    @guidance = Guidance.find(params[:id])
    authorize @guidance
    guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
    if @guidance.destroy
      unless guidance_group.guidances.where(published: true).exists?
        guidance_group.published = false
        guidance_group.save
      end
      flash[:notice] = success_message(@guidance, _("deleted"))
    else
      flash[:alert] = failure_message(@guidance, _("delete"))
    end
    redirect_to(action: :admin_index)
  end

  # PUT /org/admin/guidance/:id/admin_publish
  def admin_publish
    @guidance = Guidance.find(params[:id])
    authorize @guidance
    if @guidance.update_attributes(published: true)
      guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
      if !guidance_group.published? || guidance_group.published.nil?
        guidance_group.update(published: true)
      end
      flash[:notice] = _("Your guidance has been published and is now available to users.")

    else
      flash[:alert] = failure_message(@guidance, _("publish"))
    end
    redirect_to(action: :admin_index)
  end

  # PUT /org/admin/guidance/:id/admin_unpublish
  def admin_unpublish
    @guidance = Guidance.find(params[:id])
    authorize @guidance
    if @guidance.update_attributes(published: false)
      guidance_group = GuidanceGroup.find(@guidance.guidance_group_id)
      unless guidance_group.guidances.where(published: true).exists?
        guidance_group.update(published: false)
      end
      flash[:notice] = _("Your guidance is no longer published and will not be available to users.")

    else
      flash[:alert] = failure_message(@guidance, _("unpublish"))
    end
    redirect_to(action: :admin_index)
  end

  private

  def guidance_params
    params.require(:guidance).permit(:guidance_group_id, :text, :published, theme_ids: [])
  end

  def ensure_default_group(org)
    return unless org.managed?
    return if org.guidance_groups.where(optional_subset: false).present?

    GuidanceGroup.create_org_default(org)
  end

end
