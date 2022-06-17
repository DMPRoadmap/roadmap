# frozen_string_literal: true

# Controller for the Write plan and create plan pages
# rubocop:disable Metrics/ClassLength
class PlansController < ApplicationController
  include ConditionalUserMailer
  include OrgSelectable

  helper PaginableHelper
  helper SettingsTemplateHelper

  after_action :verify_authorized, except: [:overview]

  # GET /plans
  # rubocop:disable Metrics/AbcSize
  def index
    authorize Plan
    @plans = Plan.includes(:roles).active(current_user).page(1)
    @organisationally_or_publicly_visible = if current_user.org.is_other?
                                              []
                                            else
                                              Plan.organisationally_or_publicly_visible(current_user).page(1)
                                            end
    # TODO: Is this still used? We cannot switch this to use the :plan_params
    #       strong params because any calls that do not include `plan` in the
    #       query string will fail
    @template = Template.find(params[:plan][:template_id]) if params[:plan].present?
  end
  # rubocop:enable Metrics/AbcSize

  # GET /plans/new
  # rubocop:disable Metrics/AbcSize
  def new
    @plan = Plan.new
    authorize @plan

    # Get all of the available funders and non-funder orgs
    @funders = Org.funder
                  .includes(identifiers: :identifier_scheme)
                  .joins(:templates)
                  .where(templates: { published: true }).uniq.sort_by(&:name)
    @orgs = (Org.includes(identifiers: :identifier_scheme).organisation +
             Org.includes(identifiers: :identifier_scheme).institution +
             Org.includes(identifiers: :identifier_scheme).default_orgs)
    @orgs = @orgs.flatten.uniq.sort_by(&:name)

    @plan.org_id = current_user.org&.id

    # TODO: is this still used? We cannot switch this to use the :plan_params
    #       strong params because any calls that do not include `plan` in the
    #       query string will fail
    flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>" if params.key?(:test)
    @is_test = params[:test] ||= false
    respond_to :html
  end
  # rubocop:enable Metrics/AbcSize

  # POST /plans
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def create
    @plan = Plan.new
    authorize @plan

    # If the template_id is blank then we need to look up the available templates and
    # return JSON
    if plan_params[:template_id].blank?
      # Something went wrong there should always be a template id
      respond_to do |format|
        flash[:alert] = _('Unable to identify a suitable template for your plan.')
        format.html { redirect_to new_plan_path }
      end
    else
      @plan.visibility = if plan_params['visibility'].blank?
                           Rails.configuration.x.plans.default_visibility
                         else
                           plan_params[:visibility]
                         end

      @plan.template = Template.find(plan_params[:template_id])

      @plan.title = if plan_params[:title].blank?
                      if current_user.firstname.blank?
                        format(_('My Plan (%{title})'), title: @plan.template.title)
                      else
                        format(_('%{user_name} Plan'), user_name: "#{current_user.firstname}'s")
                      end
                    else
                      plan_params[:title]
                    end

      # bit of hackery here. There are 2 org selectors on the page
      # and each is within its own specific context, plan.org or
      # plan.funder which forces the hidden id hash to be :id
      # so we need to convert it to :org_id so it works with the
      # OrgSelectable and OrgSelection services
      if plan_params[:org].present? && plan_params[:org][:id].present?
        attrs = plan_params[:org]
        attrs[:org_id] = attrs[:id]
        @plan.org = org_from_params(params_in: attrs, allow_create: false)
      else
        # The user did not specify a research Org, so default to their Org
        @plan.org = current_user.org
      end
      if plan_params[:funder].present? && plan_params[:funder][:id].present?
        attrs = plan_params[:funder]
        attrs[:org_id] = attrs[:id]
        @plan.funder = org_from_params(params_in: attrs, allow_create: false)
      end

      if @plan.save
        # pre-select org's guidance and the default org's guidance
        ids = (Org.default_orgs.pluck(:id) << @plan.org_id).flatten.uniq
        ggs = GuidanceGroup.where(org_id: ids, optional_subset: false, published: true)

        @plan.guidance_groups << ggs unless ggs.empty?

        default = Template.default

        msg = "#{success_message(@plan, _('created'))}<br />"

        if !default.nil? && default == @plan.template
          # We used the generic/default template
          msg += " #{_('This plan is based on the default template.')}"

        elsif !@plan.template.customization_of.nil?
          # We used a customized version of the the funder template
          # rubocop:disable Layout/LineLength
          msg += " #{_('This plan is based on the')} #{@plan.funder&.name}: '#{@plan.template.title}' #{_('template with customisations by the')} #{@plan.template.org.name}"
          # rubocop:enable Layout/LineLength
        else
          # We used the specified org's or funder's template
          msg += " #{_('This plan is based on the')} #{@plan.template.org.name}: '#{@plan.template.title}' template."
        end

        @plan.add_user!(current_user.id, :creator)

        # Set new identifier to plan id by default on create.
        # (This may be changed by user.)
        @plan.identifier = @plan.id.to_s
        @plan.save

        respond_to do |format|
          flash[:notice] = msg
          format.html { redirect_to plan_path(@plan) }
        end

      else
        # Something went wrong so report the issue to the user
        respond_to do |format|
          flash[:alert] = failure_message(@plan, _('create'))
          format.html { redirect_to new_plan_path }
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # GET /plans/show
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def show
    @plan = Plan.includes(
      :guidance_groups, template: [:phases]
    ).find(params[:id])
    authorize @plan

    @visibility = if @plan.visibility.present?
                    @plan.visibility.to_s
                  else
                    Rails.configuration.x.plans.default_visibility
                  end
    # Get all of the available funders
    @funders = Org.funder
                  .joins(:templates)
                  .where(templates: { published: true }).uniq.sort_by(&:name)
    # TODO: Seems strange to do this. Why are we just not using an `edit` route?
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
    @default_orgs = Org.default_orgs
    @all_ggs_grouped_by_org.each do |org, ggs|
      @important_ggs << [org, ggs] if @default_orgs.include?(org)

      # If this is one of the already selected guidance groups its important!
      @important_ggs << [org, ggs] if !(ggs & @selected_guidance_groups).empty? && !@important_ggs.include?([org, ggs])
    end

    # Sort the rest by org name for the accordion
    @important_ggs = @important_ggs.sort_by { |org, _gg| (org.nil? ? '' : org.name) }
    @all_ggs_grouped_by_org = @all_ggs_grouped_by_org.sort_by do |org, _gg|
      (org.nil? ? '' : org.name)
    end
    @selected_guidance_groups = @selected_guidance_groups.ids

    @based_on = if @plan.template.customization_of.nil?
                  @plan.template
                else
                  Template.where(family_id: @plan.template.customization_of).first
                end

    @research_domains = ResearchDomain.all.order(:label)

    respond_to :html
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  # TODO: This feels like it belongs on a phases controller, perhaps introducing
  #       a non-namespaces phases_controller woulld make sense here. Consider
  #       doing this when we refactor the Plan editing UI
  # GET /plans/:plan_id/phases/:id/edit
  # rubocop:disable Metrics/AbcSize
  def edit
    plan = Plan.includes(
      { template: {
        phases: {
          sections: {
            questions: %i[question_format annotations]
          }
        }
      } },
      { answers: :notes }
    )
               .find(params[:id])
    authorize plan
    phase_id = params[:phase_id].to_i
    phase = plan.template.phases.select { |p| p.id == phase_id }.first
    raise ActiveRecord::RecordNotFound if phase.nil?

    guidance_groups = GuidanceGroup.where(published: true, id: plan.guidance_group_ids)
    render_phases_edit(plan, phase, guidance_groups)
  end
  # rubcocop:enable Metrics/AbcSize

  # PUT /plans/1
  # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
  def update
    @plan = Plan.find(params[:id])
    authorize @plan
    attrs = plan_params
    # rubocop:disable Metrics/BlockLength
    respond_to do |format|
      # TODO: See notes below on the pan_params definition. We should refactor
      #       this once the UI pages have been reworked
      # Save the guidance group selections
      guidance_group_ids = if params[:guidance_group_ids].blank?
                             []
                           else
                             params[:guidance_group_ids].map(&:to_i).uniq
                           end
      @plan.guidance_groups = GuidanceGroup.where(id: guidance_group_ids)

      # TODO: For some reason the `fields_for` isn't adding the
      #       appropriate namespace, so org_id represents our funder
      funder_attrs = plan_params[:funder]
      funder_attrs[:org_id] = plan_params[:funder][:id]
      funder = org_from_params(params_in: funder_attrs)
      @plan.funder_id = funder&.id
      @plan.grant = plan_params[:grant]
      attrs.delete(:funder)
      attrs.delete(:grant)
      attrs = remove_org_selection_params(params_in: attrs)

      if @plan.update(attrs) # _attributes(attrs)
        format.html do
          redirect_to plan_path(@plan),
                      notice: success_message(@plan, _('saved'))
        end
        format.json do
          render json: { code: 1, msg: success_message(@plan, _('saved')) }
        end
      else
        format.html do
          # TODO: Should do a `render :show` here instead but show defines too many
          #       instance variables in the controller
          redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
        end
        format.json do
          render json: { code: 0, msg: failure_message(@plan, _('save')) }
        end
      end
    rescue StandardError => e
      flash[:alert] = failure_message(@plan, _('save'))
      format.html do
        Rails.logger.error "Unable to save plan #{@plan&.id} - #{e.message}"
        redirect_to plan_path(@plan).to_s, alert: failure_message(@plan, _('save'))
      end
      format.json do
        render json: { code: 0, msg: flash[:alert] }
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity

  # GET /plans/:id/share
  def share
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles.where(active: true)
    else
      redirect_to(plans_path)
    end
  end

  # TODO: Does this belong on the Roles or FeedbackRequest controllers
  #       as a PUT verb?
  # GET /plans/:id/request_feedback
  def request_feedback
    @plan = Plan.find(params[:id])
    if @plan.present?
      authorize @plan
      @plan_roles = @plan.roles.where(active: true)
    else
      redirect_to(plans_path)
    end
  end

  # DELETE /plans/:id
  # rubocop:disable Metrics/AbcSize
  def destroy
    @plan = Plan.find(params[:id])
    authorize @plan
    if @plan.destroy
      respond_to do |format|
        format.html do
          redirect_to plans_url,
                      notice: success_message(@plan, _('deleted'))
        end
      end
    else
      respond_to do |format|
        flash[:alert] = failure_message(@plan, _('delete'))
        format.html { render action: 'edit' }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: Is this used? It seems like it belongs on the answers controller
  # GET /plans/:id/answer
  # rubocop:disable Metrics/AbcSize
  def answer
    @plan = Plan.find(params[:id])
    authorize @plan
    if params[:q_id].nil?
      respond_to do |format|
        format.json { render json: {} }
      end
    else
      respond_to do |format|
        format.json do
          render json: @plan.answer(params[:q_id], false).to_json(include: :options)
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # GET /plans/:id/download
  def download
    @plan = Plan.find(params[:id])
    authorize @plan
    @phase_options = @plan.phases.order(:number).pluck(:title, :id)
    @export_settings = @plan.settings(:export)
    render 'download'
  end

  # POST /plans/:id/duplicate
  # rubocop:disable Metrics/AbcSize
  def duplicate
    plan = Plan.find(params[:id])
    authorize plan
    @plan = Plan.deep_copy(plan)
    respond_to do |format|
      if @plan.save
        @plan.add_user!(current_user.id, :creator)
        format.html { redirect_to @plan, notice: success_message(@plan, _('copied')) }
      else
        format.html { redirect_to plans_path, alert: failure_message(@plan, _('copy')) }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # TODO: This should probablly just be merged with the update route
  # POST /plans/:id/visibility
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def visibility
    plan = Plan.find(params[:id])
    if plan.present?
      authorize plan
      if plan.visibility_allowed?
        plan.visibility = plan_params[:visibility]
        if plan.save
          deliver_if(recipients: plan.owner_and_coowners,
                     key: 'owners_and_coowners.visibility_changed') do |r|
            UserMailer.plan_visibility(r, plan).deliver_now
          end
          render status: :ok,
                 json: { msg: success_message(plan, _('updated')) }
        else
          render status: :internal_server_error,
                 json: { msg: failure_message(plan, _('update')) }
        end
      else
        # rubocop:disable Layout/LineLength
        render status: :forbidden, json: {
          msg: format(_("Unable to change the plan's status since it is needed at least %{percentage} percentage responded"), percentage: Rails.configuration.x.plans.default_percentage_answered)
        }
        # rubocop:enable Layout/LineLength
      end
    else
      render status: :not_found,
             json: { msg: format(_('Unable to find plan id %{plan_id}'),
                                 plan_id: params[:id]) }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # TODO: This should probablly just be merged with the update route
  # POST /plans/:id/set_test
  def set_test
    plan = Plan.find(params[:id])
    authorize plan
    plan.visibility = (params[:is_test] == '1' ? :is_test : :privately_visible)
    if plan.save
      render json: {
        code: 1,
        msg: (plan.is_test? ? _('Your project is now a test.') : _('Your project is no longer a test.'))
      }
    else
      render status: :bad_request, json: {
        code: 0, msg: _("Unable to change the plan's test status")
      }
    end
  end

  # GET /plans/:id/overview
  def overview
    plan = Plan.includes(template: [:org, { phases: { sections: :questions } }])
               .find(params[:id])

    authorize plan
    render(:overview, locals: { plan: plan })
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = format(_('There is no plan associated with id %{<id}>s'), id: params[:id])
    redirect_to(action: :index)
  end

  # ============================
  # = Private instance methods =
  # ============================

  private

  def plan_params
    # TODO: The guidance_group_ids setup on the form is a bit convoluted. Refactor
    #       it once we've started updating the UI for these pages. There should
    #       probably be a separate controller and set the checkboxes to use `remote: true`
    params.require(:plan)
          .permit(:template_id, :title, :visibility, :description, :identifier,
                  :start_date, :end_date, :org_id, :org_name, :org_crosswalk,
                  :ethical_issues, :ethical_issues_description, :ethical_issues_report,
                  :research_domain_id, :funding_status,
                  grant: %i[name value],
                  org: %i[id org_id org_name org_sources org_crosswalk],
                  funder: %i[id org_id org_name org_sources org_crosswalk])
  end

  # different versions of the same template have the same family_id
  # but different version numbers so for each set of templates with the
  # same family_id choose the highest version number.
  def get_most_recent(templates)
    groups = {}
    templates.each do |t|
      k = t.family_id
      if groups.key?(k)
        other = groups[k]
        groups[k] = t if other.version < t.version
      else
        groups[k] = t
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
    id_to_obj = {}
    plan[src_plan_key].each do |o|
      id = o[super_id]
      id_to_obj[id] = [] unless id_to_obj.key?(id)
      id_to_obj[id] << o
    end

    plan[obj_plan_key].each do |o|
      id = o['id']
      o[src_plan_key] = id_to_obj[id] if id_to_obj.key?(id)
    end
    plan.delete(src_plan_key)
  end

  def render_phases_edit(plan, phase, guidance_groups)
    readonly = !plan.editable_by?(current_user.id)
    # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
    # we create a hash whose keys are question id and value is the answer associated
    answers = plan.answers.each_with_object({}) { |a, m| m[a.question_id] = a; }
    render('/phases/edit', locals: {
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
# rubocop:enable Metrics/ClassLength
