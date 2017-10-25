class PlansController < ApplicationController
  require 'pp'
  helper SettingsTemplateHelper

  after_action :verify_authorized

  def index
    authorize Plan
    @plans = current_user.plans
  end



  # GET /plans/new
  # ------------------------------------------------------------------------------------
  def new
    @plan = Plan.new
    authorize @plan

    # Get all of the available funders and non-funder orgs
    @funders = Org.funders.joins(:templates).where(templates: {published: true}).uniq.sort{|x,y| x.name <=> y.name }
    @orgs = (Org.institutions + Org.managing_orgs).flatten.uniq.sort{|x,y| x.name <=> y.name }

    # Get the current user's org
    @default_org = current_user.org if @orgs.include?(current_user.org)

    respond_to :html
  end

  # POST /plans
  # -------------------------------------------------------------------
  def create
    @plan = Plan.new
    authorize @plan

    @plan.principal_investigator = current_user.surname.blank? ? nil : "#{current_user.firstname} #{current_user.surname}"
    @plan.data_contact = current_user.email
    @plan.funder_name = plan_params[:funder_name]

    # If a template hasn't been identified look for the available templates
    if plan_params[:template_id].blank?
      template_options(plan_params[:org_id], plan_params[:funder_id])

      # Return the 'Select a template' section
      respond_to do |format|
        format.js {}
      end

    # Otherwise create the plan
    else
      @plan.template = Template.find(plan_params[:template_id])

      if plan_params[:title].blank?
        @plan.title = current_user.firstname.blank? ? _('My Plan') + '(' + @plan.template.title + ')' :
                                    current_user.firstname + "'s" + _(" Plan")
      else
        @plan.title = plan_params[:title]
      end

      if @plan.save
        @plan.assign_creator(current_user)

        # pre-select org's guidance
        ggs = GuidanceGroup.where(org_id: plan_params[:org_id],
                                                     optional_subset: false,
                                                     published: true)
        if !ggs.blank? then @plan.guidance_groups << ggs end

        default = Template.find_by(is_default: true)

        msg = "#{_('Plan was successfully created.')} "

        if !default.nil? && default == @plan.template
          # We used the generic/default template
          msg += _('This plan is based on the default template.')

        elsif !@plan.template.customization_of.nil?
          # We used a customized version of the the funder template
          msg += "#{_('This plan is based on the')} #{plan_params[:funder_name]} #{_('template with customisations by the')} #{plan_params[:org_name]}"

        else
          # We used the specified org's or funder's template
          msg += "#{_('This plan is based on the')} #{@plan.template.org.name} template."
        end

        flash[:notice] = msg

        respond_to do |format|
          format.js { render js: "window.location='#{plan_url(@plan)}?editing=true'" }
        end

      else
        # Something went wrong so report the issue to the user
        flash[:notice] = failed_create_error(@plan, 'Plan')
        respond_to do |format|
          format.js {}
        end
      end
    end
  end



  # GET /plans/show
  def show
    @plan = Plan.eager_load(params[:id])
    authorize @plan
    @editing = (!params[:editing].nil? && @plan.administerable_by?(current_user.id))

    # Get all Guidance Groups applicable for the plan and group them by org
    @all_guidance_groups = @plan.get_guidance_group_options
    @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)

    # Important ones come first on the page - we grab the user's org's GGs and "Organisation" org type GGs
    @important_ggs = []
    @important_ggs << [current_user.org, @all_ggs_grouped_by_org.delete(current_user.org)]
    @all_ggs_grouped_by_org.each do |org, ggs|
      if org.organisation?
        @important_ggs << [org,ggs]
        @all_ggs_grouped_by_org.delete(org)
      end
    end

    # Sort the rest by org name for the accordion
    @all_ggs_grouped_by_org = @all_ggs_grouped_by_org.sort_by {|org,gg| org.name}

    @selected_guidance_groups = @plan.guidance_groups.pluck(:id)
    @based_on = (@plan.template.customization_of.nil? ? @plan.template : Template.where(dmptemplate: @plan.template.customization_of).first)

    respond_to :html
  end



  # we can go into this with the user able to edit or not able to edit
  # the same edit form gets rendered but then different partials get used
  # to render the answers depending on whether it is readonly or not
  #
  # we may or may not have a phase param.
  # if we have none then we are editing/displaying the plan details
  # if we have a phase then we are editing that phase.
  #
  # GET /plans/1/edit
  def edit
    @plan = Plan.find(params[:id])
    authorize @plan
    # If there was no phase specified use the template's 1st phase
    @phase = (params[:phase].nil? ? @plan.template.phases.first : Phase.find(params[:phase]))
    @readonly = !@plan.editable_by?(current_user.id)
    respond_to :html
  end


  # PUT /plans/1
  # PUT /plans/1.json
  def update
    @plan = Plan.find(params[:id])
    authorize @plan

    respond_to do |format|
      if @plan.update_attributes(params[:plan])
        format.html { redirect_to @plan, :editing => false, notice: _('Plan was successfully updated.') }
        format.json { head :no_content }
      else
        flash[:notice] = failed_update_error(@plan, _('plan'))
        format.html { render action: "edit" }
      end
    end
  end



  def update_guidance_choices
    @plan = Plan.find(params[:id])
    authorize @plan
    guidance_group_ids = params[:guidance_group_ids].blank? ? [] : params[:guidance_group_ids].map(&:to_i)
    all_guidance_groups = @plan.get_guidance_group_options
    plan_groups = @plan.guidance_groups
    guidance_groups = GuidanceGroup.where( id: guidance_group_ids)
    all_guidance_groups.each do |group|
      # case where plan group exists but not in selection
      if plan_groups.include?(group) && ! guidance_groups.include?(group)
      #   remove from plan groups
        @plan.guidance_groups.delete(group)
      end
      #  case where plan group dosent exist and in selection
      if !plan_groups.include?(group) && guidance_groups.include?(group)
      #   add to plan groups
        @plan.guidance_groups << group
      end
    end
    @plan.save
    flash[:notice] = _('Guidance choices saved.')
    redirect_to action: "show"
  end

  def share
    @plan = Plan.find(params[:id])
    authorize @plan
    #@plan_data = @plan.to_hash
  end


  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if @plan.destroy
      respond_to do |format|
        format.html { redirect_to plans_url, notice: _('Plan was successfully deleted.') }
      end
    else
      respond_to do |format|
        flash[:notice] = failed_create_error(@plan, _('plan'))
        format.html { render action: "edit" }
      end
    end
  end

  # GET /status/1.json
  # only returns json, why is this here?
  def status
    @plan = Plan.find(params[:id])
    authorize @plan
    respond_to do |format|
      format.json { render json: @plan.status }
    end
  end

  def answer
    @plan = Plan.find(params[:id])
    authorize @plan
    if !params[:q_id].nil?
      respond_to do |format|
        format.json { render json: @plan.answer(params[:q_id], false).to_json(:include => :options) }
      end
    else
      respond_to do |format|
        format.json { render json: {} }
      end
    end
  end

  def show_export
    @plan = Plan.find(params[:id])
    authorize @plan
    render 'show_export'
  end



  def export
    @plan = Plan.find(params[:id])
    authorize @plan

    # If no format is specified, default to PDF
    params[:format] = 'pdf' if params[:format].nil?

    @exported_plan = ExportedPlan.new.tap do |ep|
      ep.plan = @plan
      ep.phase_id = params[:phase_id]
      ep.user = current_user
      ep.format = params[:format].to_sym
      plan_settings = @plan.settings(:export)

      Settings::Template::DEFAULT_SETTINGS.each do |key, value|
        ep.settings(:export).send("#{key}=", plan_settings.send(key))
      end
    end

    begin
      @exported_plan.save!
      file_name = @exported_plan.settings(:export)[:value]['title'].gsub(/ /, "_")

      respond_to do |format|
        format.html
        format.csv  { send_data @exported_plan.as_csv,  filename: "#{file_name}.csv" }
        format.text { send_data @exported_plan.as_txt,  filename: "#{file_name}.txt" }
        format.docx { render docx: 'export', filename: "#{file_name}.docx" }
        format.pdf do
          @formatting = @plan.settings(:export).formatting
          render pdf: file_name,
            margin: @formatting[:margin],
            footer: {
              center:    _('This document was generated by %{application_name}') % {application_name: Rails.configuration.branding[:application][:name]},
              font_size: 8,
              spacing:   (@formatting[:margin][:bottom] / 2) - 4,
              right:     '[page] of [topage]'
            }
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      redirect_to show_export_plan_path(@plan), notice: _('%{format} is not a valid exporting format. Available formats to export are %{available_formats}.') %
      {format: params[:format], available_formats: ExportedPlan::VALID_FORMATS.to_s}
    end
  end



  private

  def plan_params
    params.require(:plan).permit(:org_id, :org_name, :funder_id, :funder_name, :template_id, :title)
  end

  # different versions of the same template have the same dmptemplate_id
  # but different version numbers so for each set of templates with the
  # same dmptemplate_id choose the highest version number.
  def get_most_recent( templates )
    groups = Hash.new
    templates.each do |t|
      k = t.dmptemplate_id
      if !groups.has_key?(k)
        groups[k] = t
      else
        other = groups[k]
        if other.version < t.version
          groups[k] = t
        end
      end
    end
    groups.values
  end


  def fixup_hash(plan)
    rollup(plan, "notes", "answer_id", "answers")
    rollup(plan, "answers", "question_id", "questions")
    rollup(plan, "questions", "section_id", "sections")
    rollup(plan, "sections", "phase_id", "phases")

    plan["template"]["phases"] = plan.delete("phases")

    ghash = {}
    plan["guidance_groups"].map{|g| ghash[g["id"]] = g}
    plan["plans_guidance_groups"].each do |pgg|
      pgg["guidance_group"] = ghash[ pgg["guidance_group_id"] ]
    end

    plan["template"]["org"] = Org.find(plan["template"]["org_id"]).serializable_hash()
  end


  # find all object under src_plan_key
  # merge them into the items under obj_plan_key using
  # super_id = id
  # so we have answers which each have a question_id
  # rollup(plan, "answers", "quesiton_id", "questions")
  # will put the answers into the right questions.
  def rollup(plan, src_plan_key, super_id, obj_plan_key)
    id_to_obj = Hash.new()
    plan[src_plan_key].each do |o|
      id = o[super_id]
      if !id_to_obj.has_key?(id)
        id_to_obj[id] = Array.new
      end
      id_to_obj[id]  << o
    end

    plan[obj_plan_key].each do |o|
      id = o["id"]
      if id_to_obj.has_key?(id)
        o[src_plan_key] = id_to_obj[ id ]
      end
    end
    plan.delete(src_plan_key)
  end

  # Collect all of the templates available for the org+funder combination
  # --------------------------------------------------------------------------
  def template_options(org_id, funder_id)
    @templates = []

    if org_id.present? || funder_id.present?
      if funder_id.blank?
        # Load the org's template(s)
        if org_id.present?
          org = Org.find(org_id)
          @templates = Template.valid.where(published: true, org: org, customization_of: nil).to_a
          @msg = _("We found multiple DMP templates corresponding to the research organisation.") if @templates.count > 1
        end

      else
        funder = Org.find(funder_id)
        # Load the funder's template(s)
        @templates = Template.valid.where(published: true, org: funder).to_a

        if org_id.present?
          org = Org.find(org_id)

          # Swap out any organisational cusotmizations of a funder template
          @templates.each do |tmplt|
            customization = Template.valid.find_by(published: true, org: org, customization_of: tmplt.dmptemplate_id)
            if customization.present? && tmplt.updated_at < customization.created_at
              @templates.delete(tmplt)
              @templates << customization
            end
          end
        end

        @msg = _("We found multiple DMP templates corresponding to the funder.") if @templates.count > 1
      end
    end

    # If no templates were available use the generic templates
    if @templates.empty?
      @msg = _("Using the generic Data Management Plan")
      @templates << Template.where(is_default: true, published: true).first
    end

    @templates = @templates.sort{|x,y| x.title <=> y.title } if @templates.count > 1
  end

end
