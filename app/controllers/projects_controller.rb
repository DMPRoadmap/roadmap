class ProjectsController < ApplicationController
  before_filter :get_plan_list_columns, only: %i( index )
  after_action :verify_authorized

  respond_to :html

  # GET /projects
  # -----------------------------------------------------------
  def index
    authorize Project
    ## TODO: Is this A magic String? the "Show_shib_link?" as we define it and users dont see cookies
    if user_signed_in? then
      if (current_user.shibboleth_id.nil? || current_user.shibboleth_id.length == 0) && !cookies[:show_shib_link].nil? && cookies[:show_shib_link] == "show_shib_link" then
        flash.notice = "Would you like to #{view_context.link_to I18n.t('helpers.shibboleth_to_link_text'), user_omniauth_shibboleth_path}".html_safe
      end

      @projects = current_user.projects.filter(params[:filter])
      @has_projects = current_user.projects.any? # unfiltered count

      respond_to do |format|
        format.html # index.html.erb
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    end
  end
  
  # GET /projects/1
  # GET /projects/1.json
  # -----------------------------------------------------------
  def show
    @project = Project.find(params[:id])
    authorize @project
    
    @show_form = false
    if params[:show_form] == "yes" then
      @show_form = true
    end

    if user_signed_in? && @project.readable_by(current_user.id) then
      respond_to do |format|
        format.html # show.html.erb
      end
    elsif user_signed_in? then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: I18n.t('helpers.settings.plans.errors.no_access_account') }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  # -----------------------------------------------------------
  def new
    if user_signed_in? then
      @project = Project.new
      authorize @project
      @project.organisation = current_user.organisation
      @funders = orgs_of_type(constant("organisation_types.funder"), true)
      @templates = get_available_templates
      @guidance_groups = get_available_guidance
      @always_guidance = get_always_available_guidance
      @institutions = orgs_of_type(constant("organisation_types.institution"))
      
# TODO: Would be better to determine if the user's org has templates here than in the view.
#       Replace the if Dmptemplate.own_institutional_templates check in views/projects/new with:
#          @own_org_has_templates = current_user.organisation.templates.empty?
      
      respond_to do |format|
        format.html # new.html.erb
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    end
  end

  # GET /projects/1/edit
  # Should this be removed?
  # -----------------------------------------------------------
  def edit
    @project = Project.find(params[:id])
    authorize @project
    if !user_signed_in? then
               respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@project.editable_by(current_user.id) then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: I18n.t('helpers.settings.plans.errors.no_access_account') }
      end
    end
  end

  # -----------------------------------------------------------
  def share
    @project = Project.find(params[:id])
    authorize @project
    if !user_signed_in? then
               respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@project.editable_by(current_user.id) then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: I18n.t('helpers.settings.plans.errors.no_access_account') }
      end
    end
  end

  # -----------------------------------------------------------
  def export
    @project = Project.find(params[:id])
    authorize @project
    if !user_signed_in? then
               respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    else
      # REPLACE THIS WITH CALL To LOCAL generate_export 
      # AFTER DATA MODEL REFACTOR WHEN WE COLLAPSE Projects and Plans
      
      respond_to do |format|
        format.html { render action: "export" }

      end
    end
  end

  # POST /projects
  # POST /projects.json
  # -----------------------------------------------------------
  def create
    if user_signed_in? then
      
      attrs = project_params

      @project = Project.new(attrs)
      authorize @project
      
      if @project.dmptemplate.nil? && attrs[:funder_id] != "" then # this shouldn't be necessary - see setter for funder_id in project.rb
        funder = Organisation.find(attrs[:funder_id])
        if funder.dmptemplates.count == 1 then
          @project.dmptemplate = funder.published_templates.first
        end
        
      elsif @project.dmptemplate.nil? || params[:default_tag] == 'true' then
        if @project.organisation.nil?  || params[:default_tag] == 'true'  || @project.organisation.published_templates.first.nil? then
          @project.dmptemplate = Dmptemplate.find_by_is_default(true)
        else
          @project.dmptemplate = @project.organisation.published_templates.first
        end
      end
      @project.principal_investigator = current_user.name(false)

      @project.title = I18n.t('helpers.project.my_project_name')+' ('+@project.dmptemplate.title+')'
      @project.assign_creator(current_user.id)
      respond_to do |format|
        if @project.save
          format.html { redirect_to({:action => "show", :id => @project.slug, :show_form => "yes"}, {:notice => I18n.t('helpers.project.success')}) }
        else
          format.html { render action: "new" }
        end
      end
      
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  # -----------------------------------------------------------
  def update
    @project = Project.find(params[:id])
    authorize @project
  
    if user_signed_in? && @project.editable_by(current_user.id) then
      attrs = project_params
      
      if @project.update_attributes(attrs)
        respond_to do |format|
          format.html { redirect_to({:action => "show", :id => @project.slug, notice: I18n.t('helpers.project.success_update') }) }
        end
      else
        respond_to do |format|
          format.html { render action: "edit" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  # -----------------------------------------------------------
  def destroy
    @project = Project.find(params[:id])
    authorize @project
    if user_signed_in? && @project.editable_by(current_user.id) then
      @project.destroy

      respond_to do |format|
        format.html { redirect_to projects_url }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  # returns to AJAX call from frontend 
  # difficult to secure as it passes through params, and dosent curate data based
  # on what the user can "view" or is public
  # GET /projects/possible_templates.json
  # -----------------------------------------------------------
  def possible_templates
    if !params[:funder].nil? && params[:funder] != "" && params[:funder] != "undefined" then
      funder = Organisation.find(params[:funder])
    else
      funder = nil
    end
    if !params[:institution].nil? && params[:institution] != "" && params[:institution] != "undefined" then
      institution = Organisation.find(params[:institution])
    else
      institution = nil
    end
    templates = {}
    unless funder.nil? then
      funder.published_templates.each do |t|
        templates[t.id] = t.title
      end
    end
    if templates.count == 0 && !institution.nil? then
      institution.published_templates.each do |t|
        templates[t.id] = t.title
      end
      institution.children.each do |o|
        o.published_templates.each do |t|
          templates[t.id] = t.title
        end
      end
    end
    respond_to do |format|
      format.json { render json: templates.to_json }
    end
  end

  # returns to AJAX call from frontend 
  # difficult to secure as it passes through params, and dosent curate data based
  # on what the user can "view" or is public
  # -----------------------------------------------------------
  def possible_guidance
    authorize @project
    if !params[:template].nil? && params[:template] != "" && params[:template] != "undefined" then
      template = Dmptemplate.find(params[:template])
    else
      template = nil
    end
    if !params[:institution].nil? && params[:institution] != "" && params[:institution] != "undefined" then
      institution = Organisation.find(params[:institution])
    else
      institution = nil
    end
    excluded_orgs = orgs_of_type(constant("organisation_types.funder")) + orgs_of_type(constant("organisation_types.institution")) + Organisation.orgs_with_parent_of_type(constant("organisation_types.institution"))
    guidance_groups = {}
    ggs = GuidanceGroup.guidance_groups_excluding(excluded_orgs) 

    ggs.each do |gg|
      guidance_groups[gg.id] = gg.name
    end

        #subset guidance that belong to the institution
    unless institution.nil? then
      authorize Project
      optional_gg = GuidanceGroup.where("optional_subset =  ? AND organisation_id = ?", true, institution.id)
      optional_gg.each do|optional|
        guidance_groups[optional.id] = optional.name
      end

      institution.children.each do |o|
        o.guidance_groups.each do |gg|
          include = false
          gg.guidances.each do |g|
            if g.dmptemplate.nil? || g.dmptemplate_id == template.id then
              include = true
              break
            end
          end
          if include then
            guidance_groups[gg.id] = gg.name
          end
        end
      end
    end

        #If template belongs to a funder and that funder has subset guidance display then.
        if !template.nil? && template.organisation.organisation_type.name == constant("organisation_types.funder") then
            optional_gg = GuidanceGroup.where("optional_subset =  ? AND organisation_id = ?", true, template.organisation_id)
      optional_gg.each do|optional|
        guidance_groups[optional.id] = optional.name
      end
        end


    respond_to do |format|
      format.json { render json: guidance_groups.to_json }
    end
  end
  
  # ============================================================
  private
    def project_params
      params.require(:project).permit(:title, :grant_number, :identifier, :description, 
                                     :principal_investigator, :principal_investigator_identifier,
                                     :data_contact, :funder_name, :visibility,
                                     :dmptemplate_id, :organisation_id, :funder_id, :institution_id,
                                     :guidance_group_ids, :project_group_ids)
    end
  
    # -----------------------------------------------------------
    def orgs_of_type(org_type_name, published_templates = false)
      org_type = OrganisationType.find_by_name(org_type_name)
      all_such_orgs = org_type.organisations
      if published_templates then
        with_published = Array.new
        all_such_orgs.each do |o|
          if o.published_templates.count > 0 then
            with_published << o
          end
        end
        return with_published.sort_by {|o| [o.sort_name, o.name] }
      else
        return all_such_orgs.sort_by {|o| [o.sort_name, o.name] }
      end
    end
  
    # -----------------------------------------------------------
    def get_available_templates
      Dmptemplate.where(published: true)
    end
  
    # -----------------------------------------------------------
    # Some guidance is always available to the user regardless of 
    # the template or institution. 
    #
    # TODO: Reevaluate this. We should probably only do this for 
    #       guidance groups who have guidance attached to themes 
    # -----------------------------------------------------------
    def get_always_available_guidance
      # Exclude Funders, Institutions, or children of Institutions
      excluded_orgs = orgs_of_type(constant("organisation_types.funder")) + 
                      orgs_of_type(constant("organisation_types.institution")) + 
                      Organisation.orgs_with_parent_of_type(constant("organisation_types.institution"))

      GuidanceGroup.guidance_groups_excluding(excluded_orgs) 
    end
  
    # -----------------------------------------------------------
    # This is a simplified version of the old possible_guidance method
    # above. It sends all possible guidance to the client instead of
    # forcing the client to make ajax calls to change the available
    # guidance list (that is now handled via JS clientside)
    #
    # TODO: Reevaluate whether or not this logic makes sense once the 
    #       DB has been cleaned up
    # -----------------------------------------------------------
    def get_available_guidance
      guidance_groups = []

      #subset guidance that belong to an institution
      optional_gg = GuidanceGroup.where("optional_subset =  ? AND organisation_id IS NOT NULL", true)
      optional_gg.each do|optional|
        guidance_groups << optional.id
      
        optional.organisation.children.each do |o|
          o.guidance_groups.each do |gg|
            guidance_groups << gg.id
          end
        end
      end

      # If template belongs to a funder and is an optional_subset
      optional_gg = GuidanceGroup.where("optional_subset =  ? AND organisation_id IN (?)", true, orgs_of_type(constant("organisation_types.funder")))
      optional_gg.each do|optional|
        guidance_groups << optional.id
      end
    
      GuidanceGroup.where(id: guidance_groups)
    end  

    # -----------------------------------------------------------
    def generate_export
      @exported_plan = ExportedPlan.new.tap do |ep|
        ep.plan = @plan
        ep.user = current_user ||= nil
        #ep.format = request.format.try(:symbol)
        ep.format = request.format.to_sym
        plan_settings = @plan.settings(:export)

        Settings::Dmptemplate::DEFAULT_SETTINGS.each do |key, value|
          ep.settings(:export).send("#{key}=", plan_settings.send(key))
        end
      end

      @exported_plan.save! # FIXME: handle invalid request types without erroring?
      file_name = @exported_plan.project_name

      respond_to do |format|
        format.html
        format.xml
        format.json
        format.csv  { send_data @exported_plan.as_csv, filename: "#{file_name}.csv" }
        format.text { send_data @exported_plan.as_txt, filename: "#{file_name}.txt" }
        format.docx { headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.docx\""}
        format.pdf do
          @formatting = @plan.settings(:export).formatting
          render pdf: file_name,
                 margin: @formatting[:margin],
                 footer: {
                   center: t('helpers.plan.export.pdf.generated_by'),
                   font_size: 8,
                   spacing: (@formatting[:margin][:bottom] / 2) - 4,
                   right: '[page] of [topage]'
                 }
        end
      end
    end
end
