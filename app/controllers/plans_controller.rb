class PlansController < ApplicationController
  include ConditionalUserMailer
  require 'pp'
  helper PaginableHelper
  helper SettingsTemplateHelper
  after_action :verify_authorized, except: [:overview]

  def index
    authorize Plan
    @plans = Plan.active(current_user).page(1)
    @organisationally_or_publicly_visible = Plan.organisationally_or_publicly_visible(current_user).page(1)
  end

  # GET /plans/new
  # ------------------------------------------------------------------------------------
  def new
    @plan = Plan.new
    authorize @plan

    # Get all of the available funders and non-funder orgs
    @funders = Org.funder.joins(:templates).where(templates: {published: true}).uniq.sort{|x,y| x.name <=> y.name }
    @orgs = (Org.organisation + Org.institution + Org.managing_orgs).flatten.uniq.sort{|x,y| x.name <=> y.name }

    # Get the current user's org
    @default_org = current_user.org if @orgs.include?(current_user.org) && !current_user.org.is_other?

    flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>" if params[:test]
    @is_test = params[:test] ||= false
    respond_to :html
  end

  # POST /plans
  # -------------------------------------------------------------------
  def create
    @plan = Plan.new
    authorize @plan

    # We set these ids to -1 on the page to trick ariatiseForm into allowing the autocomplete to be blank if
    # the no org/funder checkboxes are checked off
    org_id = (plan_params[:org_id] == '-1' ? '' : plan_params[:org_id])
    funder_id = (plan_params[:funder_id] == '-1' ? '' : plan_params[:funder_id])

    # If the template_id is blank then we need to look up the available templates and return JSON
    if plan_params[:template_id].blank?
      # Something went wrong there should always be a template id
      respond_to do |format|
        flash[:alert] = _('Unable to identify a suitable template for your plan.')
        format.html { redirect_to new_plan_path }
      end
    else
      # Otherwise create the plan
      @plan.principal_investigator = current_user.surname.blank? ? nil : "#{current_user.firstname} #{current_user.surname}"
      @plan.principal_investigator_email = current_user.email

      orcid = current_user.identifier_for(IdentifierScheme.find_by(name: 'orcid'))
      @plan.principal_investigator_identifier = orcid.identifier unless orcid.nil?

      @plan.funder_name = plan_params[:funder_name]

      @plan.visibility = (plan_params['visibility'].blank? ? Rails.application.config.default_plan_visibility :
                                                             plan_params[:visibility])

      @plan.template = Template.find(plan_params[:template_id])

      if plan_params[:title].blank?
        @plan.title = current_user.firstname.blank? ? _('My Plan') + '(' + @plan.template.title + ')' :
                                    current_user.firstname + "'s" + _(" Plan")
      else
        @plan.title = plan_params[:title]
      end

      if @plan.save
        @plan.assign_creator(current_user)

        # pre-select org's guidance and the default org's guidance
       
        # DMPTool hack to select UCOP DMPTool guidance
        #ids = (Org.managing_orgs << org_id).flatten.uniq
        ids = [Org.find_by(abbreviation: 'UCOP').id, org_id].uniq
        ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

        if !ggs.blank? then @plan.guidance_groups << ggs end

        default = Template.default

        msg = "#{success_message(_('plan'), _('created'))}<br />"

        if !default.nil? && default == @plan.template
          # We used the generic/default template
          msg += " #{_('This plan is based on the default template.')}"

        elsif !@plan.template.customization_of.nil?
          # We used a customized version of the the funder template
          msg += " #{_('This plan is based on the')} #{plan_params[:funder_name]}: '#{@plan.template.title}' #{_('template with customisations by the')} #{plan_params[:org_name]}"

        else
          # We used the specified org's or funder's template
          msg += " #{_('This plan is based on the')} #{@plan.template.org.name}: '#{@plan.template.title}' template."
        end

        respond_to do |format|
          flash[:notice] = msg
          format.html { redirect_to plan_path(@plan) }
        end

      else
        # Something went wrong so report the issue to the user
        respond_to do |format|
          flash[:alert] = failed_create_error(@plan, 'Plan')
          format.html { redirect_to new_plan_path }
        end
      end
    end
  end

  # GET /plans/show
  def show
    @plan = Plan.eager_load(params[:id])
    authorize @plan

    @visibility = @plan.visibility.present? ? @plan.visibility.to_s : Rails.application.config.default_plan_visibility

    @editing = (!params[:editing].nil? && @plan.administerable_by?(current_user.id))

    # Get all Guidance Groups applicable for the plan and group them by org
    @all_guidance_groups = @plan.get_guidance_group_options
    @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
    @selected_guidance_groups = @plan.guidance_groups

    # Important ones come first on the page - we grab the user's org's GGs and "Organisation" org type GGs
    @important_ggs = []

    @important_ggs << [current_user.org, @all_ggs_grouped_by_org[current_user.org]] if @all_ggs_grouped_by_org.include?(current_user.org)
    @all_ggs_grouped_by_org.each do |org, ggs|
      if org.organisation?
        @important_ggs << [org,ggs]
      end

      # If this is one of the already selected guidance groups its important!
      if !(ggs & @selected_guidance_groups).empty?
        @important_ggs << [org,ggs] unless @important_ggs.include?([org,ggs])
      end
    end

    # Sort the rest by org name for the accordion
    @important_ggs = @important_ggs.uniq.sort_by{|org,gg| (org.nil? ? '' : org.name)}
    @all_ggs_grouped_by_org = @all_ggs_grouped_by_org.sort_by {|org,gg| (org.nil? ? '' : org.name)}
    @selected_guidance_groups = @selected_guidance_groups.collect{|gg| gg.id}

    @based_on = (@plan.template.customization_of.nil? ? @plan.template : Template.where(family_id: @plan.template.customization_of).first)

    respond_to :html
  end

  # GET /plans/:plan_id/phases/:id/edit
  def edit
    plan = Plan.find(params[:id])
    authorize plan
    
    plan, phase = Plan.load_for_phase(params[:id], params[:phase_id])
    
    readonly = !plan.editable_by?(current_user.id)
    
    guidance_groups_ids = plan.guidance_groups.collect(&:id)
    
    guidance_groups =  GuidanceGroup.where(published: true, id: guidance_groups_ids)
    # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
    # we create a hash whose keys are question id and value is the answer associated
    answers = plan.answers.reduce({}){ |m, a| m[a.question_id] = a; m }
    
    render('/phases/edit', locals: {
      base_template_org: phase.template.base_org,
      plan: plan, phase: phase, readonly: readonly,
      question_guidance: plan.guidance_by_question_as_hash,
      guidance_groups: guidance_groups,
      answers: answers })
  end
  
  # PUT /plans/1
  # PUT /plans/1.json
  def update
    @plan = Plan.find(params[:id])
    authorize @plan
    attrs = plan_params

    respond_to do |format|
      begin
        # Save the guidance group selections
        guidance_group_ids = params[:guidance_group_ids].blank? ? [] : params[:guidance_group_ids].map(&:to_i).uniq
        @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)
        @plan.save
      
        if @plan.update_attributes(attrs)
          format.html { redirect_to overview_plan_path(@plan), notice: success_message(_('plan'), _('saved')) }
          format.json {render json: {code: 1, msg: success_message(_('plan'), _('saved'))}}
        else
          flash[:alert] = failed_update_error(@plan, _('plan'))
          format.html { render action: "edit" }
          format.json {render json: {code: 0, msg: flash[:alert]}}
        end
        
      rescue Exception
        flash[:alert] = failed_update_error(@plan, _('plan'))
        format.html { render action: "edit" }
        format.json {render json: {code: 0, msg: flash[:alert]}}
      end
    end
  end

  def share
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      # Get the roles where the user is not a reviewer
      @plan_roles = @plan.roles.select{ |r| !r.reviewer? }
    else
      redirect_to(plans_path)
    end
  end


  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if @plan.destroy
      respond_to do |format|
        format.html { redirect_to plans_url, notice: success_message(_('plan'), _('deleted')) }
      end
    else
      respond_to do |format|
        flash[:alert] = failed_create_error(@plan, _('plan'))
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

  def download
    @plan = Plan.find(params[:id])
    authorize @plan
    @phase_options = @plan.phases.order(:number).pluck(:title,:id)
    @export_settings = @plan.settings(:export)
    render 'download'
  end



  def export
    @plan = Plan.includes(:answers).find(params[:id])
    authorize @plan

    @show_coversheet = params[:export][:project_details].present?
    @show_sections_questions = params[:export][:question_headings].present?
    @show_unanswered = params[:export][:unanswered_questions].present?
    @public_plan = false

    @hash = @plan.as_pdf(@show_coversheet)
    @formatting = params[:export][:formatting] || @plan.settings(:export).formatting
    file_name = @plan.title.gsub(/ /, "_").gsub('/\n/', '').gsub('/\r/', '').gsub(':', '_')
    file_name = file_name[0..30] if file_name.length > 31


    respond_to do |format|
      format.html { render layout: false }
      format.csv  { send_data @plan.as_csv(@show_sections_questions),  filename: "#{file_name}.csv" }
      format.text { send_data render_to_string(partial: 'shared/export/plan_txt'), filename: "#{file_name}.txt" }
      format.docx { render docx: "#{file_name}.docx", content: render_to_string(partial: 'shared/export/plan') }
      format.pdf do
        render pdf: file_name,
               margin: @formatting[:margin],
               footer: {
                 center:    _('Created using the %{application_name}. Last modified %{date}') % {application_name: Rails.configuration.branding[:application][:name], date: l(@plan.updated_at.to_date, formats: :short)},
                 font_size: 8,
                 spacing:   (Integer(@formatting[:margin][:bottom]) / 2) - 4,
                 right:     '[page] of [topage]'
               }
      end
    end
  end


  def duplicate
    plan = Plan.find(params[:id])
    authorize plan
    @plan = Plan.deep_copy(plan)
    respond_to do |format|
      if @plan.save
        @plan.assign_creator(current_user)
        format.html { redirect_to @plan, notice: success_message(_('plan'), _('copied')) }
      else
        format.html { redirect_to plans_path, alert: failed_create_error(@plan, 'Plan') }
      end
    end
  end

  # POST /plans/:id/visibility
  def visibility
    plan = Plan.find(params[:id])
    if plan.present?
      authorize plan
      if plan.visibility_allowed?
        plan.visibility = plan_params[:visibility]
        if plan.save
          deliver_if(recipients: plan.owner_and_coowners, key: 'owners_and_coowners.visibility_changed') do |r|
            UserMailer.plan_visibility(r,plan).deliver_now()
          end
          render status: :ok, json: { msg: success_message(_('plan\'s visibility'), _('changed')) }
        else
          render status: :internal_server_error, json: { msg: _('Error raised while saving the visibility for plan id %{plan_id}') %{ :plan_id => params[:id]} }
        end
      else
        render status: :forbidden, json: {
          msg: _('Unable to change the plan\'s status since it is needed at least '\
            '%{percentage} percentage responded') %{ :percentage => Rails.application.config.default_plan_percentage_answered } }
      end
    else
      render status: :not_found, json: { msg: _('Unable to find plan id %{plan_id}') %{ :plan_id => params[:id]} }
    end
  end

  def set_test
    plan = Plan.find(params[:id])
    authorize plan
    plan.visibility = (params[:is_test] === "1" ? :is_test : :privately_visible)
    if plan.save
      render json: {code: 1, msg: (plan.is_test? ? _('Your project is now a test.') : _('Your project is no longer a test.') )}
    else
      render status: :bad_request, json: {code: 0, msg: _("Unable to change the plan's test status")}
    end
  end

  def request_feedback
    plan = Plan.find(params[:id])
    authorize plan
    alert = _('Unable to submit your request for feedback at this time.')

    begin
     if plan.request_feedback(current_user)
       redirect_to share_plan_path(plan), notice: _('Your request for feedback has been submitted.')
     else
       redirect_to share_plan_path(plan), alert: alert
     end
    rescue Exception
      redirect_to share_plan_path(plan), alert: alert
    end
  end

  def overview
    begin
      plan = Plan.overview(params[:id])
      authorize plan
      render(:overview, locals: { plan: plan })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = _('There is no plan associated with id %{id}') %{ :id => params[:id] }
      redirect_to(action: :index)
    end
  end

  private
  def plan_params
    params.require(:plan).permit(:org_id, :org_name, :funder_id, :funder_name, :template_id, :title, :visibility,
                                 :grant_number, :description, :identifier, :principal_investigator,
                                 :principal_investigator_email, :principal_investigator_identifier,
                                 :data_contact, :data_contact_email, :data_contact_phone, :guidance_group_ids)
  end


  # different versions of the same template have the same family_id
  # but different version numbers so for each set of templates with the
  # same family_id choose the highest version number.
  def get_most_recent( templates )
    groups = Hash.new
    templates.each do |t|
      k = t.family_id
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
end
