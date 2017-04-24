class PlansController < ApplicationController
  require 'pp'
  helper SettingsTemplateHelper
  #Uncomment the line below in order to add authentication to this page - users without permission will not be able to add new plans
  #load_and_authorize_resource
  #
	before_filter :get_plan_list_columns, only: %i( index )
  after_action :verify_authorized


  def index
    authorize Plan
    @plans = current_user.plans
  end



  # GET /plans/new
  def new
    @plan = Plan.new
    authorize @plan
    @funders = Org.funders.all 

    no_org = Org.new()
    no_org.id = -1
    no_org.name = "No Funder"
    @funders.unshift(no_org)


    respond_to do |format|
      format.html # new.html.erb
    end
  end


  # we get here either from selecting a funder or if if the first selection
  # results in multiple templates, from a template selection screen
  def create
    @plan = Plan.new
    authorize @plan
    
    message = ""

    # if we have a template_id we've been selcting between templates, otherwise funders
    if params[:template_id]
      @templates = [ Template.find(params[:template_id] ) ]
    else
      funder_id = params[:plan][:funder_id].to_i

      if funder_id.present? && funder_id != -1
        @templates = []

        # get all funder @templates
        funder = Org.find(params[:plan][:funder_id])
        funder_templates = get_most_recent( funder.templates.where(published: true).all )

        # get org templates and index by customization id
        if current_user.org.nil?
          orgtemplates = []
        else
          orgtemplates = get_most_recent( current_user.org.templates.all )
        end
        
        orgt_by_customization = orgtemplates.collect{|t| [t.customization_of, t]}.to_h

        # go through funder templates and replace with org cusomizations if needed
        funder_templates.each do |ft|
          if orgt_by_customization.has_key?(ft.dmptemplate_id)
            message = _(" - using template customised by your institution")
            @templates << orgt_by_customization[ft.dmptemplate_id]
          else
            @templates << ft
          end
        end
        
      else # either didn't select funder or selected "No Funder"

        # get all org @templates which are not customisations
        @templates = get_most_recent( current_user.org.templates.where(customization_of: nil) )

        message = _(" - choosing default template for your institution")

        # if none of these get the default template
        if @templates.blank?
          @templates = get_most_recent( Template.where(is_default: true, customization_of: nil) )
          message = _(" - no funder or institution template, choosing default template")
        end
      end
    end

    # if we have more than one template then back to the user
    # using the 'create' template
    # to choose otherwise just create the plan
    # and go to the plan/show template
    if @templates.length > 1 
      message += _(" - there are more than one to choose from")
      flash.notice = message
      respond_to do |format|
        format.html
      end
      return
    end

    @plan.template = @templates[0]

    @based_on = @plan.base_template()

    @plan.principal_investigator = current_user.name

    @plan.title = _('My plan')+' ('+@plan.template.title+')'  # We should use interpolated string since the order of the words from this message could vary among languages

    @all_guidance_groups = @plan.get_guidance_group_options
    @selected_guidance_groups = @plan.guidance_groups.pluck(:id)

    respond_to do |format|
      if @plan.save
        @plan.assign_creator(current_user.id)
        flash.notice = _('Plan was successfully created.') + message
        format.html { redirect_to({:action => "show", :id => @plan.id, :editing => true }) }
      else
        flash[:notice] = failed_create_error(@plan, _('plan'))
        format.html { render action: "new" }
      end
    end
  end



  # GET /plans/show
  def show
    @plan = Plan.eager_load(params[:id])
    authorize @plan
    @editing = (!params[:editing].nil? && @plan.administerable_by?(current_user.id))
    @all_guidance_groups = @plan.get_guidance_group_options
    @selected_guidance_groups = @plan.plan_guidance_groups.pluck(:guidance_group_id)
    @based_on = @plan.base_template

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
    @readonly = @plan.editable_by?(current_user.id)
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


# TODO: Remove these endpoints now that we're no longer using them
=begin
  def section_answers
    @plan = Plan.find(params[:id])
    authorize @plan
    respond_to do |format|
      format.json { render json: @plan.section_answers(params[:section_id]) }
    end
  end

  def locked
    @plan = Plan.find(params[:id])
    authorize @plan
    if !@plan.nil? && user_signed_in? && @plan.readable_by(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.locked(params[:section_id],current_user.id) }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def delete_recent_locks
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by(current_user.id) then
      respond_to do |format|
        if @plan.delete_recent_locks(current_user.id)
          format.html { render action: "edit" }
        else
          format.html { render action: "edit" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def unlock_all_sections
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by(current_user.id) then
      respond_to do |format|
        if @plan.unlock_all_sections(current_user.id)
          format.html { render action: "edit" }
        else
          format.html { render action: "edit" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def lock_section
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by(current_user.id) then
      respond_to do |format|
        if @plan.lock_section(params[:section_id], current_user.id)
          format.html { render action: "edit" }
        else
          format.html { render action: "edit" }
          format.json { render json: @plan.errors, status: :unprocessable_entity }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def unlock_section
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by(current_user.id) then
      respond_to do |format|
        if @plan.unlock_section(params[:section_id], current_user.id)
          format.html { render action: "edit" }

        else
          format.html { render action: "edit" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end
=end

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
      file_name = @plan.title.gsub(/ /, "_")

      respond_to do |format|
        format.html
        format.csv  { send_data @exported_plan.as_csv, filename: "#{file_name}.csv" }
        format.text { send_data @exported_plan.as_txt, filename: "#{file_name}.txt" }
        format.docx { headers["Content-Disposition"] = "attachment; filename=\"#{file_name}.docx\""}
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
    plan["plan_guidance_groups"].each do |pgg|
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

end
