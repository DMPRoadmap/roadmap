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
    authorize Plan
    
    @plan = Plan.new
    authorize @plan
    @funders = Org.funders.all 

    respond_to do |format|
      format.html # new.html.erb
    end
  end


  def create
    if user_signed_in? then
      @plan = Plan.new
      @plan.save
      authorize @plan

      if params[:template_id]
        @templates = [ Template.find(params[:template_id] ) ]
      else

          funder_id = params[:plan][:funder_id]
          if !funder_id.blank?
            # get all funder @templates
            funder = Org.find(params[:plan][:funder_id])
            @templates = get_most_recent( funder.templates.where("published = ?", true).all )

            orgtemplates = current_user.org.templates.all
            replacements = []

            # replace any that are customised by the org
            orgtemplates.each do |orgt|
              base_template = orgt.customization_of 
              @templates.delete(base_template)
              replacements << orgt
            end
            @templates + replacements

          else
            # get all org @templates which are not customisations
            @templates = current_user.org.templates.where(customization_of: nil)

            # if none of these get the basic dcc template
            if @templates.blank?
              @templates = Template.find_by_is_default(true)
            end
          end
      end

      # if we have more than one template then back to the user
      # using the 'create' template
      # to choose otherwise just create the plan
      # and go to the plan/show template
      if @templates.length > 1 
        return
      end

      @plan.template = @templates[0]

      @plan.principal_investigator = current_user.name

      @plan.title = _('My plan')+' ('+@plan.template.title+')'  # We should use interpolated string since the order of the words from this message could vary among languages

      @plan.assign_creator(current_user.id)

      @plan.set_possible_guidance_groups

      @selected_guidance_groups = @plan.guidance_groups.map{ |pgg| [pgg.name, pgg.id, :checked => false] }
      @selected_guidance_groups.sort!
      
      respond_to do |format|
        if @plan.save
          format.html { redirect_to({:action => "show", :id => @plan.id, :editing => true }, {:notice => _('Plan was successfully created.')}) }
        else
          @error = "Something went wrong" 
          format.html { render action: "new" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end



  # GET /plans/show
  def show
    puts 'plans#show'
    @plan = Plan.eager_load(params[:id])
    authorize @plan

    @editing = params[:editing] && @plan.administerable_by?(current_user.id)
    @selected_guidance_groups = []
    all_guidance_groups = @plan.plan_guidance_groups
    @selected_guidance_groups = all_guidance_groups.map{ |pgg| [ pgg.guidance_group.name, pgg.guidance_group.id, :checked => pgg.selected ] }
    @selected_guidance_groups.sort!

    if user_signed_in? && @plan.readable_by?(current_user.id) then
      respond_to do |format|
        format.html # show.html.erb
      end
    elsif user_signed_in? then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: _('This account does not have access to that plan.') }
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    end
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

    @phase = nil
    if params[:phase]
      @phase = Phase.find(params[:phase])
    end

    authorize @plan
    @readonly = @plan.editable_by?(current_user.id)
    if !user_signed_in? then
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@plan.readable_by?(current_user.id) then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: _('This account does not have access to that plan.') }
      end
    end
  end

  # PUT /plans/1
  # PUT /plans/1.json
  def update
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by?(current_user.id) then
      respond_to do |format|
        if @plan.update_attributes(params[:plan])
          format.html { redirect_to @plan, :editing => false, notice: _('Plan was successfully updated.') }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
        end
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end



  def update_guidance_choices
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by?(current_user.id) then
      guidance_ids = params[:plan][:plan_guidance_group_ids]
      @plan.plan_guidance_groups.each do |pgg|
        pgg.selected = guidance_ids.include?(pgg.guidance_group_id.to_s)
        pgg.save!
      end
      @plan.save!

      respond_to do |format|
        format.json { head :no_content }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def share
    @plan = Plan.find(params[:id])
    authorize @plan
    @plan_data = @plan.to_hash
    if !user_signed_in? then
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@plan.editable_by?(current_user.id) then
      respond_to do |format|
        format.html { redirect_to plans_url, notice: _('This account does not have access to that plan.') }
      end
    end
  end


  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by?(current_user.id) then
      @plan.destroy

      respond_to do |format|
        format.html { redirect_to plans_url }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  # GET /status/1.json
  # only returns json, why is this here?
  def status
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.readable_by(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.status }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
    end
  end

  def section_answers
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.readable_by(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.section_answers(params[:section_id]) }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
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

  def answer
    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.readable_by(current_user.id) then
      respond_to do |format|
        format.json { render json: @plan.answer(params[:q_id], false).to_json(:include => :options) }
      end
    else
      render(:file => File.join(Rails.root, 'public/403.html'), :status => 403, :layout => false)
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

    if user_signed_in? && @plan.readable_by?(current_user.id) then
      @exported_plan = ExportedPlan.new.tap do |ep|
        ep.plan = @plan
        ep.user = current_user
        ep.format = params[:format].to_sym
        plan_settings = @plan.settings(:export)

        Settings::Template::DEFAULT_SETTINGS.each do |key, value|
          ep.settings(:export).send("#{key}=", plan_settings.send(key))
        end
      end

      begin
        @exported_plan.save!
        file_name = @exported_plan.project_name

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
    elsif !user_signed_in? then
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@plan.editable_by(current_user.id) then
      respond_to do |format|
        format.html { redirect_to plans_path, notice: _('This account does not have access to that plan.') }
      end
    end
  end



  private


  def get_most_recent( templates )
    groups = Hash.new
    templates.each do |t|
      k = t.dmptemplate_id
      if !groups.has_key?(k)
        groups[k] =t
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
