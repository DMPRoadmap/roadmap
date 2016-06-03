class GuidanceGroupsController < ApplicationController
	
  
  # GET /guidance_groups/1
  # GET /guidance_groups/1.json
  def admin_show
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance_group = GuidanceGroup.find(params[:id])
	
	    respond_to do |format|
	      format.html 
	      format.json { render json: @guidance_group }
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
  end

	
	# GET add new guidance groups
	def admin_new
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance_group = GuidanceGroup.new
	    	
	    respond_to do |format|
	      format.html # new.html.erb
	      format.json { render json: @guidance }
	    end
   	end
	end 
 
  # POST /guidance_groups
  # POST /guidance_groups.json
  def admin_create
    if user_signed_in? && current_user.is_org_admin? then
	    @guidance_group = GuidanceGroup.new(params[:guidance_group])
	    @guidance_group.organisation_id = current_user.organisation_id
        if params[:save_publish] 
            @guidance_group.published = true
        end
	
	    respond_to do |format|
	      if @guidance_group.save
	        format.html { redirect_to admin_index_guidance_path, notice: I18n.t('org_admin.guidance_group.created_message') }
	        format.json { render json: @guidance_group, status: :created, location: @guidance_group }
	      else
	        format.html { render action: "new" }
	        format.json { render json: @guidance_group.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
  end
  
  # GET /guidance_groups/1/edit
  def admin_edit
  	if user_signed_in? && current_user.is_org_admin? then
      @guidance_group = GuidanceGroup.find(params[:id])
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
  end

  # PUT /guidance_groups/1
  # PUT /guidance_groups/1.json
  def admin_update
 		if user_signed_in? && current_user.is_org_admin? then
   		@guidance_group = GuidanceGroup.find(params[:id])
	    @guidance_group.organisation_id = current_user.organisation_id

	    respond_to do |format|
	      if @guidance_group.update_attributes(params[:guidance_group])
	        format.html { redirect_to admin_index_guidance_path(params[:guidance_group]), notice: I18n.t('org_admin.guidance_group.updated_message') }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @guidance_group.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
  end
  
  # PUT /guidance_groups/1
  def admin_update_publish
 		if user_signed_in? && current_user.is_org_admin? then
   		@guidance_group = GuidanceGroup.find(params[:id])
	    @guidance_group.organisation_id = current_user.organisation_id
        @guidance_group.published = true

	    respond_to do |format|
	      if @guidance_group.update_attributes(params[:guidance_group])
	        format.html { redirect_to admin_index_guidance_path(params[:guidance_group]), notice: I18n.t('org_admin.guidance_group.updated_message') }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @guidance_group.errors, status: :unprocessable_entity }
	      end
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
  end


  # DELETE /guidance_groups/1
  # DELETE /guidance_groups/1.json
  def admin_destroy
  	if user_signed_in? && current_user.is_org_admin? then
	   	@guidance_group = GuidanceGroup.find(params[:id])
	    @guidance_group.destroy
	
	    respond_to do |format|
	      format.html { redirect_to admin_index_guidance_path, notice: I18n.t('org_admin.guidance_group.destroyed_message') }
	      format.json { head :no_content }
	    end
	 	else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
	
	end
  
  
end