class PlanExportsController < ApplicationController

  def show
    @show_coversheet         = params[:export][:project_details].present?
    @show_sections_questions = params[:export][:question_headings].present?
    @show_unanswered         = params[:export][:unanswered_questions].present?
    @show_custom_sections    = params[:export][:custom_sections].present?

    @plan = Plan.includes(:answers).find(params[:plan_id])
    authorize @plan, :export?
    @selected_phase = @plan.phases.find(params[:phase_id])
    @public_plan    = false
    @hash           = @plan.as_pdf(@show_coversheet)
    @formatting     = params[:export][:formatting] || @plan.settings(:export).formatting

    respond_to do |format|
      format.html { show_html }
      format.csv  { show_csv }
      format.text { show_text }
      format.docx { show_docx }
      format.pdf  { show_pdf }
    end
  end

  private

  def show_html
    render layout: false
  end

  def show_csv
    send_data @plan.as_csv(@show_sections_questions,
                           @show_unanswered,
                           @selected_phase,
                           @show_custom_sections,
                           @show_coversheet),
              filename: "#{file_name}.csv"
  end

  def show_text
    send_data render_to_string(partial: 'shared/export/plan_txt'),
              filename: "#{file_name}.txt"
  end

  def show_docx
    render docx: "#{file_name}.docx",
           content: render_to_string(partial: 'shared/export/plan')
  end

  def show_pdf
    render pdf: file_name,
           margin: @formatting[:margin],
           footer: {
             center: _("Created using the %{application_name}. Last modified %{date}") % {
               application_name: Rails.configuration.branding[:application][:name],
               date: l(@plan.updated_at.to_date, formats: :short)
              },
             font_size: 8,
             spacing:   (Integer(@formatting[:margin][:bottom]) / 2) - 4,
             right:     "[page] of [topage]"
           }
  end

  def file_name
    @plan.title.gsub(/ /, "_")
  end
end
