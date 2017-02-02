class PlansController < ApplicationController
  #Uncomment the line below in order to add authentication to this page - users without permission will not be able to add new plans
  #load_and_authorize_resource
  after_action :verify_authorized

  TEXTAREA = QuestionFormat.where(title: "Text area").first.id
  TEXTFIELD = QuestionFormat.where(title: "Text field").first.id
  RADIO = QuestionFormat.where(title: "Radio buttons").first.id
  CHECKBOX = QuestionFormat.where(title: "Check box").first.id
  DROPDOWN = QuestionFormat.where(title: "Dropdown").first.id
  MULTI = QuestionFormat.where(title: "Multi select box").first.id

  def index
    authorize Plan
    @plans = current_user.plans
  end



  # GET /plans/new
  def new
    if user_signed_in? then
      @plan = Plan.new
      authorize @plan
      @funders = Org.funder.all 

      respond_to do |format|
        format.html # new.html.erb
      end
    else
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    end
  end


  def create
    if user_signed_in? then
      @plan = Plan.new
      authorize @plan
      @plan.save

      funder_id = params[:plan][:funder_id]
      if !funder_id.blank?
        # get all funder @templates
        funder = Org.find(params[:plan][:funder_id])
        logger.debug "RAY: funder = " + funder.inspect 
        @templates = get_most_recent( funder.templates.where("published = ?", true).all )
        logger.debug "RAY: found "+ @templates.count.to_s + " templates = " + @templates.inspect

        orgtemplates = current_user.org.templates.all
        logger.debug "RAY: found "+ @templates.count.to_s + " org templates = " + @templates.inspect
        replacements = []

        # replace any that are customised by the org
        orgtemplates.each do |orgt|
          base_template = orgt.customization_of 
          @templates.delete(base_template)
          replacements << orgt
        end
        @templates + replacements
        logger.debug "RAY: finally "+ @templates.count.to_s + " templates = " + @templates.inspect

      else
        # get all org @templates which are not customisations
        @templates = current_user.org.templates.where(customization_of: nil)

        # if none of these get the basic dcc template
        if @templates.blank?
          @templates = Template.find_by_is_default(true)
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

      @plan.title = I18n.t('helpers.project.my_project_name')+' ('+@plan.template.title+')'

      @plan.assign_creator(current_user.id)

      @plan.set_possible_guidance_groups

      @selected_guidance_groups = @plan.guidance_groups.map{ |pgg| [pgg.name, pgg.id, :checked => false] }
      @selected_guidance_groups.sort!
      
      respond_to do |format|
        if @plan.save
          #format.html { redirect_to({:action => "show", :id => @plan.slug, :show_form => "yes"}, {:notice => I18n.t('helpers.project.success')}) }
          format.html { redirect_to({:action => "show", :id => @plan.id, :editing => true }, {:notice => I18n.t('helpers.project.success')}) }
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
    @plan = Plan.find(params[:id])
    authorize @plan
    @editing = params[:editing] && @plan.administerable_by?(current_user.id)
    @selected_guidance_groups = []
    @selected_guidance_groups = @plan.plan_guidance_groups.map{ |pgg| [pgg.guidance_group.name, pgg.guidance_group.id, :checked => pgg.selected] }
    @selected_guidance_groups.sort!

    if user_signed_in? && @plan.readable_by?(current_user.id) then
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
    @textarea = TEXTAREA
    @textfield = TEXTFIELD
    @radio = RADIO
    @checkbox = CHECKBOX
    @dropdown = DROPDOWN
    @multi = MULTI

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
        format.html { redirect_to projects_url, notice: I18n.t('helpers.settings.plans.errors.no_access_account') }
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
          format.html { redirect_to @plan, :editing => false, notice: I18n.t('helpers.project.success_update') }
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
    logger.debug "RAY: update_guidance_choices with params"
    logger.debug params.inspect

    @plan = Plan.find(params[:id])
    authorize @plan
    if user_signed_in? && @plan.editable_by?(current_user.id) then
      guidance_ids = params[:plan][:guidances]
      logger.debug "RAY: guidance ids = " + guidance_ids.inspect
      @plan.plan_guidance_groups.each do |pgg|
        logger.debug "RAY: looking at pgg = " + pgg.inspect
        pgg.selected = guidance_ids.include?(pgg.guidance_group_id.to_s)
        logger.debug "RAY: pg now = " + pgg.inspect
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

  def export
    @plan = Plan.find(params[:id])
    authorize @plan

    if user_signed_in? && @plan.readable_by(current_user.id) then
      @exported_plan = ExportedPlan.new.tap do |ep|
        ep.plan = @plan
        ep.user = current_user
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
              center:    t('helpers.plan.export.pdf.generated_by'),
              font_size: 8,
              spacing:   (@formatting[:margin][:bottom] / 2) - 4,
              right:     '[page] of [topage]'
            }
        end
      end
    elsif !user_signed_in? then
      respond_to do |format|
        format.html { redirect_to edit_user_registration_path }
      end
    elsif !@plan.editable_by(current_user.id) then
      respond_to do |format|
        format.html { redirect_to projects_url, notice: I18n.t('helpers.settings.plans.errors.no_access_account') }
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

end
