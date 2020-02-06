# frozen_string_literal: true

class PlansController < ApplicationController

  include ConditionalUserMailer
  helper PaginableHelper
  helper SettingsTemplateHelper

  after_action :verify_authorized, except: [:overview]

  def index
    authorize Plan
    @plans = Plan.active(current_user).page(1)
    if current_user.org.is_other?
      @organisationally_or_publicly_visible = []
    else
      @organisationally_or_publicly_visible =
        Plan.organisationally_or_publicly_visible(current_user).page(1)
    end

    if params[:plan].present?
      @template = Template.find(params[:plan][:template_id])
    end
  end

  # GET /plans/new
  def new
    @plan = Plan.new
    authorize @plan

    # Get all of the available funders and non-funder orgs
    @funders = Org.funder
                  .joins(:templates)
                  .where(templates: { published: true }).uniq.sort_by(&:name)
    @orgs = (Org.organisation + Org.institution + Org.default_orgs)
    @orgs = @orgs.flatten.uniq.sort_by(&:name)

    # Get the current user's org
    @default_org = current_user.org if @orgs.include?(current_user.org)

    if params.key?(:test)
      flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>"
    end
    @is_test = params[:test] ||= false
    respond_to :html
  end

  # POST /plans
  def create
    @plan = Plan.new
    authorize @plan

    # We set these ids to -1 on the page to trick ariatiseForm into allowing the
    # autocomplete to be blank if the no org/funder checkboxes are checked off
    org_id = (plan_params[:org_id] == "-1" ? "" : plan_params[:org_id])
    funder_id = (plan_params[:funder_id] == "-1" ? "" : plan_params[:funder_id])

    # If the template_id is blank then we need to look up the available templates and
    # return JSON
    if plan_params[:template_id].blank?
      # Something went wrong there should always be a template id
      respond_to do |format|
        flash[:alert] = _("Unable to identify a suitable template for your plan.")
        format.html { redirect_to new_plan_path }
      end
    else
      # Otherwise create the plan
      if current_user.surname.blank?
        @plan.principal_investigator = nil
      else
        @plan.principal_investigator = current_user.name(false)
      end

      @plan.principal_investigator_email = current_user.email

      orcid = current_user.identifiers.by_scheme_name("orcid", "Org").first
      @plan.principal_investigator_identifier = orcid.value unless orcid.nil?

      @plan.funder_name = plan_params[:funder_name]

      @plan.visibility = if plan_params["visibility"].blank?
                           Rails.application.config.default_plan_visibility
                         else
                           plan_params[:visibility]
                         end

      @plan.template = Template.find(plan_params[:template_id])

      if plan_params[:title].blank?
        @plan.title = if current_user.firstname.blank?
                        _("My Plan") + "(" + @plan.template.title + ")"
                      else
                        current_user.firstname + "'s" + _(" Plan")
                      end
      else
        @plan.title = plan_params[:title]
      end

      if @plan.save
        # pre-select org's guidance and the default org's guidance
        ids = (Org.default_orgs.pluck(:id) << org_id).flatten.uniq
        ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

        if !ggs.blank? then @plan.guidance_groups << ggs end

        default = Template.default

        msg = "#{success_message(@plan, _('created'))}<br />"

        if !default.nil? && default == @plan.template
          # We used the generic/default template
          msg += " #{_('This plan is based on the default template.')}"

        elsif !@plan.template.customization_of.nil?
          # rubocop:disable Metrics/LineLength
          # We used a customized version of the the funder template
          # rubocop:disable Metrics/LineLength
          msg += " #{_('This plan is based on the')} #{plan_params[:funder_name]}: '#{@plan.template.title}' #{_('template with customisations by the')} #{plan_params[:org_name]}"
          # rubocop:enable Metrics/LineLength
        else
          # rubocop:disable Metrics/LineLength
          # We used the specified org's or funder's template
          # rubocop:disable Metrics/LineLength
          msg += " #{_('This plan is based on the')} #{@plan.template.org.name}: '#{@plan.template.title}' template."
          # rubocop:enable Metrics/LineLength
        end

        @plan.add_user!(current_user.id, :creator)

        # Set new identifier to plan id by default on create.
        # (This may be changed by user.)
        @plan.add_identifier!(@plan.id.to_s)

        respond_to do |format|
          flash[:notice] = msg
          format.html { redirect_to plan_path(@plan) }
        end

      else
        # Something went wrong so report the issue to the user
        respond_to do |format|
          flash[:alert] = failure_message(@plan, _("create"))
          format.html { redirect_to new_plan_path }
        end
      end
    end
  end

  # GET /plans/show
  def show
    @plan = Plan.includes(
      template: { phases: { sections: { questions: :answers } } },
      plans_guidance_groups: { guidance_group: :guidances }
            ).find(params[:id])
    authorize @plan

    @visibility = if @plan.visibility.present?
                    @plan.visibility.to_s
                  else
                    Rails.application.config.default_plan_visibility
                  end

    @editing = (!params[:editing].nil? && @plan.administerable_by?(current_user.id))

    # Get all Guidance Groups applicable for the plan and group them by org
    @all_guidance_groups = @plan.guidance_group_options
    @all_ggs_grouped_by_org = @all_guidance_groups.sort.group_by(&:org)
    @selected_guidance_groups = @plan.guidance_groups

    # Important ones come first on the page - we grab the user's org's GGs and
    # "Organisation" org type GGs
    @important_ggs = []

    if @all_ggs_grouped_by_org.include?(current_user.org)
      @important_ggs << [current_user.org, @all_ggs_grouped_by_org[current_user.org]]
    end
    @all_ggs_grouped_by_org.each do |org, ggs|
      if org.organisation?
        @important_ggs << [org, ggs]
      end

      # If this is one of the already selected guidance groups its important!
      if !(ggs & @selected_guidance_groups).empty?
        @important_ggs << [org, ggs] unless @important_ggs.include?([org, ggs])
      end
    end

    # Sort the rest by org name for the accordion
    @important_ggs = @important_ggs.sort_by { |org, gg| (org.nil? ? "" : org.name) }
    @all_ggs_grouped_by_org = @all_ggs_grouped_by_org.sort_by do |org, gg|
      (org.nil? ? "" : org.name)
    end
    @selected_guidance_groups = @selected_guidance_groups.ids

    @based_on = if @plan.template.customization_of.nil?
                  @plan.template
                else
                  Template.where(family_id: @plan.template.customization_of).first
                end
    respond_to :html
  end

  # GET /plans/:plan_id/phases/:id/edit
  def edit
    plan = Plan.find(params[:id])
    authorize plan
    plan, phase = Plan.load_for_phase(params[:id], params[:phase_id])
    guidance_groups = GuidanceGroup.where(published: true, id: plan.guidance_group_ids)
    render_phases_edit(plan, phase, guidance_groups)
  end

  # PUT /plans/1
  # PUT /plans/1.json
  def update
    @plan = Plan.find(params[:id])
    authorize @plan
    attrs = plan_params
    # rubocop:disable Metrics/BlockLength
    respond_to do |format|
      begin
        # Save the guidance group selections
        guidance_group_ids = if params[:guidance_group_ids].blank?
                               []
                             else
                               params[:guidance_group_ids].map(&:to_i).uniq
                             end
        @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)
        @plan.save
        if @plan.update_attributes(attrs)
          format.html do
            redirect_to overview_plan_path(@plan),
                        notice: success_message(@plan, _("saved"))
          end
          format.json do
            render json: { code: 1, msg: success_message(@plan, _("saved")) }
          end
        else
          format.html do
            # TODO: Should do a `render :show` here instead but show defines too many
            #       instance variables in the controller
            redirect_to "#{plan_path(@plan)}", alert: failure_message(@plan, _("save"))
          end
          format.json do
            render json: { code: 0, msg: failure_message(@plan, _("save")) }
          end
        end

      rescue Exception
        flash[:alert] = failure_message(@plan, _("save"))
        format.html do
          render_phases_edit(@plan, @plan.phases.first, @plan.guidance_groups)
        end
        format.json do
          render json: { code: 0, msg: flash[:alert] }
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end

  def share
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles
    else
      redirect_to(plans_path)
    end
  end

  def request_feedback
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles
    else
      redirect_to(plans_path)
    end
  end

  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if @plan.destroy
      respond_to do |format|
        format.html do
          redirect_to plans_url,
                      notice: success_message(@plan, _("deleted"))
        end
      end
    else
      respond_to do |format|
        flash[:alert] = failure_message(@plan, _("delete"))
        format.html { render action: "edit" }
      end
    end
  end

  def answer
    @plan = Plan.find(params[:id])
    authorize @plan
    if !params[:q_id].nil?
      respond_to do |format|
        format.json do
          render json: @plan.answer(params[:q_id], false).to_json(include: :options)
        end
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
    @phase_options = @plan.phases.order(:number).pluck(:title, :id)
    @export_settings = @plan.settings(:export)
    render "download"
  end

  def duplicate
    plan = Plan.find(params[:id])
    authorize plan
    @plan = Plan.deep_copy(plan)
    respond_to do |format|
      if @plan.save
        @plan.add_user!(current_user.id, :creator)
        format.html { redirect_to @plan, notice: success_message(@plan, _("copied")) }
      else
        format.html { redirect_to plans_path, alert: failure_message(@plan, _("copy")) }
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
          deliver_if(recipients: plan.owner_and_coowners,
                     key: "owners_and_coowners.visibility_changed") do |r|
            UserMailer.plan_visibility(r, plan).deliver_now()
          end
          render status: :ok,
                 json: { msg: success_message(plan, _("updated")) }
        else
          render status: :internal_server_error,
                 json: { msg: failure_message(plan, _("update")) }
        end
      else
        # rubocop:disable Metrics/LineLength
        render status: :forbidden, json: {
          msg: _("Unable to change the plan's status since it is needed at least %{percentage} percentage responded") % {
              percentage: Rails.application.config.default_plan_percentage_answered
          }
        }
        # rubocop:enable Metrics/LineLength
      end
    else
      render status: :not_found,
             json: { msg: _("Unable to find plan id %{plan_id}") % {
               plan_id: params[:id] }
             }
    end
  end

  def set_test
    plan = Plan.find(params[:id])
    authorize plan
    plan.visibility = (params[:is_test] === "1" ? :is_test : :privately_visible)
    # rubocop:disable Metrics/LineLength
    if plan.save
      render json: {
               code: 1,
               msg: (plan.is_test? ? _("Your project is now a test.") : _("Your project is no longer a test."))
             }
    else
      render status: :bad_request, json: {
               code: 0, msg: _("Unable to change the plan's test status")
             }
    end
    # rubocop:enable Metrics/LineLength
  end

  def overview
    begin
      plan = Plan.includes(:phases, :sections, :questions, template: [ :org ])
                 .find(params[:id])

      authorize plan
      render(:overview, locals: { plan: plan })
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = _("There is no plan associated with id %{id}") % {
        id: params[:id]
      }
      redirect_to(action: :index)
    end
  end

  private

  def plan_params
    params.require(:plan)
          .permit(:org_id, :org_name, :funder_id, :funder_name, :template_id,
                  :title, :visibility, :grant_number, :description, :identifier,
                  :principal_investigator_phone, :principal_investigator,
                  :principal_investigator_email, :data_contact,
                  :principal_investigator_identifier, :data_contact_email,
                  :data_contact_phone, :guidance_group_ids)
  end

  # different versions of the same template have the same family_id
  # but different version numbers so for each set of templates with the
  # same family_id choose the highest version number.
  def get_most_recent(templates)
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
      id_to_obj[id] << o
    end

    plan[obj_plan_key].each do |o|
      id = o["id"]
      if id_to_obj.has_key?(id)
        o[src_plan_key] = id_to_obj[ id ]
      end
    end
    plan.delete(src_plan_key)
  end

  private

  # ============================
  # = Private instance methods =
  # ============================

  def render_phases_edit(plan, phase, guidance_groups)
    readonly = !plan.editable_by?(current_user.id)
    # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
    # we create a hash whose keys are question id and value is the answer associated
    answers = plan.answers.reduce({}) { |m, a| m[a.question_id] = a; m }
    render("/phases/edit", locals: {
      base_template_org: phase.template.base_org,
      plan: plan,
      phase: phase,
      readonly: readonly,
      guidance_groups: guidance_groups,
      answers: answers,
      guidance_presenter: GuidancePresenter.new(plan)
    })
  end

end
