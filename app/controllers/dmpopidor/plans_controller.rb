# frozen_string_literal: true

module Dmpopidor
  module PlansController
    # CHANGES:
    # Added Active Flag on Org
    # rubocop:disable Metrics/AbcSize
    def new
      @plan = ::Plan.new
      authorize @plan

      # Get all of the available funders and non-funder orgs
      @funders = ::Org.funder
                      .includes(identifiers: :identifier_scheme)
                      .joins(:templates)
                      .where(templates: { published: true }).uniq.sort_by(&:name)
      @orgs = (::Org.includes(identifiers: :identifier_scheme).managed.organisation +
               ::Org.includes(identifiers: :identifier_scheme).managed.institution +
               ::Org.includes(identifiers: :identifier_scheme).managed.default_orgs)
      @orgs = @orgs.flatten
                   .select { |org| org.active == true }
                   .uniq.sort_by(&:name)

      @plan.org_id = current_user.org&.id

      # Get the default template
      @default_template = ::Template.default

      # TODO: is this still used? We cannot switch this to use the :plan_params
      #       strong params because any calls that do not include `plan` in the
      #       query string will fail
      flash[:notice] = "#{_('This is a')} <strong>#{_('test plan')}</strong>" if params.key?(:test)
      @is_test = params[:test] ||= false
      respond_to :html
    end
    # rubocop:enable Metrics/AbcSize

    def budget
      @plan = ::Plan.find(params[:id])
      dmp_fragment = @plan.json_fragment
      @costs = Fragment::Cost.where(dmp_id: dmp_fragment.id)
      authorize @plan
      render(:budget, locals: { plan: @plan, costs: @costs })
    end

    private

    # CHANGES : Removed everything except guidances group info. The rest of the info is
    # handled by MadmpFragmentController
    def plan_params
      params.require(:plan)
            .permit(:org_id, :template_id, :funder_name, :visibility,
                    :title, :org_name, :guidance_group_ids,
                    research_outputs_attributes: %i[_destroy],
                    org: %i[id org_id org_name org_sources org_crosswalk],
                    funder: %i[id org_id org_name org_sources org_crosswalk])
    end

    # Get the parameters corresponding to the schema
    def schema_params(schema, form_prefix, flat: false)
      s_params = schema.generate_strong_params(flat: flat)
      params.require(:plan)[form_prefix].permit(s_params)
    end

    # CHANGES : maDMP Fragments SUPPORT
    def render_phases_edit(plan, phase, guidance_groups)
      readonly = !plan.editable_by?(current_user.id)
      @schemas = ::MadmpSchema.all
      # Since the answers have been pre-fetched through plan (see Plan.load_for_phase)
      # we create a hash whose keys are question id and value is the answer associated
      answers = plan.answers
                    .includes(:madmp_fragment)
                    .each_with_object({}) { |a, m| m["#{a.question_id}_#{a.research_output_id}"] = a }
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
end
