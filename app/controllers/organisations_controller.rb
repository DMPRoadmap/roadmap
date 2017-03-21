class OrganisationsController < ApplicationController
  after_action :verify_authorized

  # GET /organisations/1
  def admin_show
    @organisation = Organisation.find(params[:id])
    authorize @organisation
    respond_to do |format|
      format.html # show.html.erb
    end
  end

   # GET /organisations/1/edit
  def admin_edit
    @organisation = Organisation.find(params[:id])
    authorize @organisation
    
    @languages = Language.all.order("name")
  end


  # PUT /organisations/1
  def admin_update
    @organisation = Organisation.find(params[:id])
    authorize @organisation
    @organisation.banner_text = params["org_banner_text"]
    @organisation.logo = params[:organisation][:logo] if params[:organisation][:logo]
    assign_params = params[:organisation].dup
    assign_params.delete(:logo)
    assign_params.delete(:contact_email) unless params[:organisation][:contact_email].present?
    
    respond_to do |format|
      begin
        if @organisation.update_attributes(assign_params)
          format.html { redirect_to admin_show_organisation_path(params[:id]), notice: I18n.t("admin.org_updated_message")  }
        else
          flash[:noice] = @organisation.errors.collect{|e| e.message}.join('<br />').html_safe
          format.html { render action: "admin_edit" }
        end
        
      rescue Dragonfly::Job::Fetch::NotFound => dflye
        flash[:notice] = I18n.t("admin.org_bad_logo")
        format.html {render action: "admin_edit"}
      end
    end
  end

  #TODO: see if this is used by the ajax... otherwise lock it down
  def parent
  	@organisation = Organisation.find(params[:id])
    authorize @organisation
  	parent_org = @organisation.find_by {|o| o.parent_id }
  	return parent_org
  end

  #TODO: see is this is used by the ajax... otherwise lock it down
	def children
		@organisation = Organisation.find(params[:id])
    authorize @organisation
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

  #TODO: see if this is used by the ajax... otherwise lock it down
	def templates
		@organisation = Organisation.find(params[:id])
    authorize @organisation
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
