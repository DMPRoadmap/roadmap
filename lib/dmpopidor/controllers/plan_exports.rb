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
            @formatting     = export_params[:formatting] || @plan.settings(:export).formattingz
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
            end
          end
        
      end
    end
  end