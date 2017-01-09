class GuidanceGroupsController < ApplicationController
  after_action :verify_authorized

  # GET /guidance_groups/1
  def admin_show
    @guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    respond_to do |format|
      format.html
    end
  end


	# GET add new guidance groups
	def admin_new
    @guidance_group = GuidanceGroup.new
    authorize @guidance_group
    respond_to do |format|
      format.html # new.html.erb
    end
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

    respond_to do |format|
      if @guidance_group.save
        format.html { redirect_to admin_index_guidance_path, notice: I18n.t('org_admin.guidance_group.created_message') }
      else
        format.html { render action: "new" }
      end
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
    respond_to do |format|
      if @guidance_group.update_attributes(params[:guidance_group])
        format.html { redirect_to admin_index_guidance_path(params[:guidance_group]), notice: I18n.t('org_admin.guidance_group.updated_message') }
      else
        format.html { render action: "edit" }
      end
    end
  end


  # PUT /guidance_groups/1
  def admin_update_publish
 		@guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.organisation_id = current_user.organisation_id
      @guidance_group.published = true

    respond_to do |format|
      if @guidance_group.update_attributes(params[:guidance_group])
        format.html { redirect_to admin_index_guidance_path(params[:guidance_group]), notice: I18n.t('org_admin.guidance_group.updated_message') }
      else
        format.html { render action: "edit" }
      end
    end
  end


  # DELETE /guidance_groups/1
  # DELETE /guidance_groups/1.json
  def admin_destroy
   	@guidance_group = GuidanceGroup.find(params[:id])
    authorize @guidance_group
    @guidance_group.destroy
    respond_to do |format|
      format.html { redirect_to admin_index_guidance_path, notice: I18n.t('org_admin.guidance_group.destroyed_message') }
    end
	end

end