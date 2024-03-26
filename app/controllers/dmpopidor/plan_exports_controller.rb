# frozen_string_literal: true

module Dmpopidor
  # Customized code for PlanExportsController
  module PlanExportsController
    # CHANGES: Can now send multiple phases when exporting
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def show
      @plan = ::Plan.includes(:answers, :research_outputs, {
                                template: { phases: { sections: :questions } }
                              }).find(params[:plan_id])

      if privately_authorized? && export_params[:form].present?
        skip_authorization
        @show_coversheet         = export_params[:project_details].present?
        @show_sections_questions = export_params[:question_headings].present?
        @show_unanswered         = export_params[:unanswered_questions].present?
        @show_complete_data      = export_params[:complete_data].present?
        @show_custom_sections    = export_params[:custom_sections].present?
        @show_research_outputs   = true
        @public_plan             = false

      elsif publicly_authorized?
        skip_authorization
        @show_coversheet         = true
        @show_sections_questions = true
        @show_unanswered         = true
        @show_custom_sections    = true
        @show_research_outputs   = true
        @public_plan             = true

      else
        raise Pundit::NotAuthorizedError
      end

      @hash           = @plan.as_pdf(current_user, @show_coversheet)
      @formatting     = export_params[:formatting] || @plan.settings(:export).formatting
      @research_output_export_mode = export_params[:research_output_mode] || 'by_section'

      if params.key?(:selected_phases)
        @hash[:phases] = @hash[:phases].select { |p| params[:selected_phases].include?(p[:id].to_s) }
      end

      # Added contributors to coverage of plans.
      # Users will see both roles and contributor names if the role is filled
      # @hash[:data_curation] = Contributor.where(plan_id: @plan.id).data_curation
      # @hash[:investigation] = Contributor.where(plan_id: @plan.id).investigation
      # @hash[:pa] = Contributor.where(plan_id: @plan.id).project_administration
      # @hash[:other] = Contributor.where(plan_id: @plan.id).other

      if params.key?(:research_outputs)
        @hash[:research_outputs] = @hash[:research_outputs].order(display_order: :asc).select do |d|
          params[:research_outputs].include?(d[:id].to_s)
        end
      end

      respond_to do |format|
        format.html { show_html }
        format.csv  { show_csv }
        format.text { show_text }
        format.docx { show_docx }
        format.pdf  { show_pdf }
        format.json do
          selected_research_outputs = params[:research_outputs]&.map(&:to_i) || @plan.research_output_ids
          show_json(selected_research_outputs, params[:json_format])
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # CHANGES: PDF footer now displays DMP licence
    # rubocop:disable Metrics/AbcSize
    def show_pdf
      license = @plan.json_fragment.meta.license if @plan.template.structured?
      license_details = if license.present? && !license.data.compact.empty?
                          "#{license.data['licenseName']} (#{license.data['licenseUrl']})"
                        end
      render pdf: file_name,
             margin: @formatting[:margin],
             footer:
             {
               center: license_details,
               font_size: 8,
               spacing: (Integer(@formatting[:margin][:bottom]) / 2) - 4,
               right: '[page] of [topage]',
               encoding: 'utf8'
             }
    end
    # rubocop:enable Metrics/AbcSize

    # CHANGES: Changed JSON export to use madmp_fragments
    def show_json(selected_research_outputs, json_format)
      send_data render_to_string("shared/export/madmp_export_templates/#{json_format}/plan",
                                 locals: {
                                   dmp: @plan.json_fragment,
                                   selected_research_outputs: selected_research_outputs
                                 }), filename: "#{file_name}_#{json_format}.json"
    end

    def export_params
      params.fetch(:export, {})
            .permit(:form, :project_details, :question_headings, :unanswered_questions, :complete_data,
                    :custom_sections, :research_outputs, :research_output_mode, :selected_phases,
                    formatting: [:font_face, :font_size, { margin: %i[top right bottom left] }])
    end
  end
end
