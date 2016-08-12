class OrganisationsController < ApplicationController
  # GET /organisations
  # GET /organisations.json
  def index
    @organisations = Organisation.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisations }
    end
  end

  # GET /organisations/new
  # GET /organisations/new.json
  def new
    @organisation = Organisation.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organisation }
    end
  end

  # POST /organisations
  # POST /organisations.json
  def create
    @organisation = Organisation.new(params[:organisation])
    @organisation.logo = param[:organisation][:logo]
    respond_to do |format|
      if @organisation.save
        format.html { redirect_to @organisation, notice: I18n.t("admin.org_created_message") }
        format.json { render json: @organisation, status: :created, location: @organisation }
      else
        format.html { render action: "new" }
        format.json { render json: @organisation.errors, status: :unprocessable_entity }
      end
    end
  end

  
  # GET /organisations/1
  # GET /organisations/1.json
  def admin_show
  	if user_signed_in? && current_user.is_org_admin? then
	    @organisation = Organisation.find(params[:id])
	
	    respond_to do |format|
	      format.html # show.html.erb
	      format.json { render json: @organisation }
	    end
    else
			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
		end 
		
  end
  
   # GET /organisations/1/edit
  def admin_edit
  	if user_signed_in? && current_user.is_org_admin? then
        @organisation = Organisation.find(params[:id])
    
    else
		render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
	end 
  end
  
  
  # PUT /organisations/1
  # PUT /organisations/1.json
  def admin_update
    if user_signed_in? && current_user.is_org_admin? then
        @organisation = Organisation.find(params[:id])
        @organisation.banner_text = params["org_banner_text"]
        @organisation.logo = params[:organisation][:logo] if params[:organisation][:logo]
	assign_params = params[:organisation].dup
	assign_params.delete(:logo)			
		
	    respond_to do |format|
	      if @organisation.update_attributes(assign_params)
	        format.html { redirect_to admin_show_organisation_path(params[:id]), notice: I18n.t("admin.org_updated_message")  }
	        format.json { head :no_content }
	      else
               	flash[:alert] = I18n.t("org_admin.org_logo_failed_message")
                format.html { render action: "admin_edit" }
	        format.json { render json: @organisation.errors, status: :unprocessable_entity }
	      end
	    end
  	else
  	  render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end  	
  end

  # DELETE /organisations/1
  # DELETE /organisations/1.json
  def destroy
    @organisation = Organisation.find(params[:id])
    @organisation.destroy

    respond_to do |format|
      format.html { redirect_to organisations_url }
      format.json { head :no_content }
    end
  end
  
  def parent
  	@organisation = Organisation.find(params[:id])
  	parent_org = @organisation.find_by {|o| o.parent_id }
  	return parent_org
  end
  
	def children
		@organisation = Organisation.find(params[:id])
		#if user_signed_in? then
		children = {}
		@organisation.children.each do |child|
			children[child.id] = child.name
		end
		respond_to do |format|
			format.json { render json: children.to_json }
		end
# 		else
# 			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
# 		end
	end
  
	def templates
		@organisation = Organisation.find(params[:id])
		#if user_signed_in? then
		templates = {}
		@organisation.dmptemplates.each do |template|
			if template.is_published? then
				templates[template.id] = template.title
			end
		end
		respond_to do |format|
			format.json { render json: templates.to_json }
		end
# 		else
# 			render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
# 		end
	end
end
