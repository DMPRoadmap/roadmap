module Dmpopidor
    module Controllers
      module PlanExports

        # CHANGES: Can now send multiple phases when exporting
        def show
            @plan = Plan.includes(:answers).find(params[:plan_id])
        
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

            if params.key?(:selected_phases)
                @hash[:phases] = @hash[:phases].select { |p| params[:selected_phases].include?(p[:id].to_s)}
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