# frozen_string_literal: true

# Controller for the Plan Download page
class PlanExportsController < ApplicationController
  after_action :verify_authorized

  include ConditionsHelper

  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
  def show
    @plan = Plan.includes(:answers, { template: { phases: { sections: :questions } } })
                .find(params[:plan_id])

    if privately_authorized? && export_params[:form].present?
      skip_authorization
      @show_coversheet          = export_params[:project_details].present?

      # DMPTool customization
      # ----------------------
      # Remove single :question_headings and replace with separate :section_headings and
      # :question_text
      #
      # @show_sections_questions  = export_params[:question_headings].present?
      @show_sections            = export_params[:section_headings].present?
      @show_questions           = export_params[:question_text].present?

      @show_unanswered          = export_params[:unanswered_questions].present?
      @show_custom_sections     = export_params[:custom_sections].present?
      @show_research_outputs    = export_params[:research_outputs].present?
      @show_related_identifiers = export_params[:related_identifiers].present?
      @formatting               = export_params[:formatting]
      @formatting               = @plan.settings(:export)&.formatting if @formatting.nil?
      @public_plan              = false

    elsif publicly_authorized?
      skip_authorization
      @show_coversheet          = true

      # DMPTool customization
      # ----------------------
      # Remove single :question_headings and replace with separate :section_headings and :question_text
      #
      # @show_sections_questions  = true
      @show_sections            = true
      @show_questions           = true

      @show_unanswered          = true
      @show_custom_sections     = true
      @show_research_outputs    = @plan.research_outputs&.any? || false
      @show_related_identifiers = @plan.related_identifiers&.any? || false
      @formatting               = @plan.settings(:export)&.formatting
      @formatting               = Settings::Template::DEFAULT_SETTINGS if @formatting.nil?
      @public_plan              = true

    else
      raise Pundit::NotAuthorizedError, _('are not authorized to view that plan')
    end

    @hash           = @plan.as_pdf(current_user, @show_coversheet)
    @formatting     = export_params[:formatting] || @plan.settings(:export).formatting
    if params.key?(:phase_id) && params[:phase_id].length.positive?
      # order phases by phase number asc
      @hash[:phases] = @hash[:phases].sort_by { |phase| phase[:number] }
      if params[:phase_id] == 'All'
        @hash[:all_phases] = true
      else
        @selected_phase = @plan.phases.find(params[:phase_id])
      end
    else
      @selected_phase = @plan.phases.order('phases.updated_at DESC')
                             .detect { |p| p.visibility_allowed?(@plan) }
    end

    # Bug fix in the event that there was no phase with visibility_allowed
    @selected_phase = @plan.phases.order('phases.updated_at DESC').first if @selected_phase.blank?

    # Added contributors to coverage of plans.
    # Users will see both roles and contributor names if the role is filled
    @hash[:data_curation] = Contributor.where(plan_id: @plan.id).data_curation
    @hash[:investigation] = Contributor.where(plan_id: @plan.id).investigation
    @hash[:pa] = Contributor.where(plan_id: @plan.id).project_administration
    @hash[:other] = Contributor.where(plan_id: @plan.id).other

    respond_to do |format|
      format.html { show_html }
      format.csv  { show_csv }
      format.text { show_text }
      format.docx { show_docx }
      format.pdf  { show_pdf }
      format.json { show_json }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity

  private

  def show_html
    render layout: false
  end

  def show_csv
    send_data @plan.as_csv(current_user, @show_questions,
                           @show_unanswered,
                           @selected_phase,
                           @show_custom_sections,
                           @show_coversheet,
                           @show_research_outputs,
                           @show_related_identifiers),
              filename: "#{file_name}.csv"
  end

  def show_text
    send_data render_to_string(partial: 'shared/export/plan_txt'),
              filename: "#{file_name}.txt"
  end

  def show_docx
    # Using and optional locals_assign export_format
    render docx: "#{file_name}.docx",
           content: clean_html_for_docx_creation(render_to_string(partial: 'shared/export/plan',
                                                                  locals: { export_format: 'docx' }))
  end

  def show_pdf
    # If the plan is a registered DMP ID, then just go get it's PDF stored in S3
    if @plan.narrative_url.present?
      redirect_to @plan.narrative_url
    else
      render pdf: file_name,
            margin: @formatting[:margin],
            # wkhtmltopdf behavior is based on the OS so force the zoom level
            # See 'Gotchas' section of https://github.com/mileszs/wicked_pdf
            # zoom: 0.78125,
            # show_as_html: params.key?('debug'),
            page_size: 'Letter',
            footer: {
              center: format(_('Created using %{application_name}. Last modified %{date}'),
                              application_name: ApplicationService.application_name,
                              date: l(@plan.updated_at.localtime.to_date, format: :readable)),
              font_size: 8,
              spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
              right: _('[page] of [topage]'),
              encoding: 'utf8'
            }
    end
  end

  def show_json
    # If it's a registered DMP ID, then get the JSON from the DMPHub
    json = DmpIdService.fetch_dmp_id(dmp_id: @plan.dmp_id) if @plan.dmp_id.present?

    if json.nil?
      json = render_to_string(partial: '/api/v2/plans/show',
                              locals: { plan: @plan, client: current_user })
      json = "{\"dmp\":#{json}}"
    end

    render json: json
  end

  def file_name
    # Sanitize bad characters and replace spaces with underscores
    ret = @plan.title
    ret = ret.strip.gsub(/\s+/, '_')
    ret = ret.delete('"')
    ret = ActiveStorage::Filename.new(ret).sanitized
    # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
    # of 255 characters, so this should provide enough of the title to allow the user
    # to understand which DMP it is and still allow for the file to be saved to a deeply
    # nested directory
    ret[0, 100]
  end

  def publicly_authorized?
    PublicPagePolicy.new(current_user, @plan).plan_organisationally_exportable? ||
      PublicPagePolicy.new(current_user, @plan).plan_export?
  end

  def privately_authorized?
    if current_user.present?
      PlanPolicy.new(current_user, @plan).export?
    else
      false
    end
  end

  def export_params
    # DMPTool customization
    # ----------------------
    # Remove single :question_headings and replace with separate :section_headings and :question_text
    #
    params.require(:export)
          .permit(:form, :project_details, :section_headings, :question_text, :unanswered_questions,
                  :custom_sections, :research_outputs, :related_identifiers,
                  formatting: [:font_face, :font_size, { margin: %i[top right bottom left] }])
  end

  # A method to deal with problematic text combinations
  # in html that break docx creation by htmltoword gem.
  def clean_html_for_docx_creation(html)
    # Replaces single backslash \ with \\ with gsub.
    html.gsub('\\', '\&\&')
  end
end
