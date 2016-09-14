class OrganisationsController < ApplicationController
<<<<<<< 38417884f7c8dfce6cb3b255ddd4410f0fba2157
  #after_action :verify_authorized

  # GET /organisations
  # GET /organisations.json
  def index
    #authorize Organisation
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
    #authorize @organisation

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

=======
  after_action :verify_authorized
>>>>>>> forced auth on organisations_controller.  TODO: re-check parent, children, and templates after AJAX removed

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
  end


  # PUT /organisations/1
  def admin_update
    @organisation = Organisation.find(params[:id])
    authorize @organisation
    @organisation.banner_text = params["org_banner_text"]
    @organisation.logo = params[:organisation][:logo] if params[:organisation][:logo]
    assign_params = params[:organisation].dup
    assign_params.delete(:logo)
    
    respond_to do |format|
      if @organisation.update_attributes(assign_params)
        format.html { redirect_to admin_show_organisation_path(params[:id]), notice: I18n.t("admin.org_updated_message")  }
      else
        format.html { render action: "edit" }
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
