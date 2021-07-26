# frozen_string_literal: true

module Dmpopidor

  module Controllers

    module PlanExports

      # CHANGES: Can now send multiple phases when exporting
      def show
        @plan = Plan.includes(:answers, :research_outputs).find(params[:plan_id])

        if privately_authorized? && export_params[:form].present?
          skip_authorization
          @show_coversheet         = export_params[:project_details].present?
          @show_sections_questions = export_params[:question_headings].present?
          @show_unanswered         = export_params[:unanswered_questions].present?
          @show_custom_sections    = export_params[:custom_sections].present?
          @public_plan             = false

        elsif publicly_authorized?
          skip_authorization
          @show_coversheet         = true
          @show_sections_questions = true
          @show_unanswered         = true
          @show_custom_sections    = true
          @public_plan             = true

        else
          raise Pundit::NotAuthorizedError
        end

        @hash           = @plan.as_pdf(@show_coversheet)
        @formatting     = export_params[:formatting] || @plan.settings(:export).formatting
        @research_output_export_mode = export_params[:research_output_mode] ? export_params[:research_output_mode] : 'by_section'
        @research_outputs_number = @plan.research_outputs.length

        if @formatting.nil?
          @formatting     = Settings::Template::DEFAULT_SETTINGS[:formatting]
        end

        if params.key?(:selected_phases)
          @hash[:phases] = @hash[:phases].select { |p| params[:selected_phases].include?(p[:id].to_s)}
        end

        if params.key?(:selected_research_outputs)
          @hash[:research_outputs] = @hash[:research_outputs].select { |d| params[:selected_research_outputs].include?(d[:id].to_s)}
        end

        respond_to do |format|
          format.html { show_html }
          format.csv  { show_csv }
          format.text { show_text }
          format.docx { show_docx }
          format.pdf  { show_pdf }
          format.json {
            selected_research_outputs = params[:selected_research_outputs]&.map(&:to_i) || @plan.research_output_ids
            show_json(selected_research_outputs, params[:json_format])
          }
        end
      end

      # CHANGES: Changed footer
      def show_pdf
        render pdf: file_name,
               margin: @formatting[:margin],
               footer: {
                 center: d_("dmpopidor", "%{plan_title} - Last modified %{date}") % {
                   plan_title: @plan.title,
                   date: l(@plan.updated_at.to_date, format: :readable)
                 },
                 font_size: 8,
                 spacing:   (Integer(@formatting[:margin][:bottom]) / 2) - 4,
                 right:     "[page] of [topage]",
                 encoding: "utf8"
               }
      end

      def show_json(selected_research_outputs, json_format)
        send_data render_to_string("shared/export/madmp_export_templates/#{json_format}/plan", 
                locals: {
                dmp: @plan.json_fragment,
                selected_research_outputs: selected_research_outputs
              }),
              filename: "#{file_name}_#{json_format}.json"
      end

    end

  end

end