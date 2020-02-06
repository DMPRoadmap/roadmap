# frozen_string_literal: true

class PlanExportsController < ApplicationController

  after_action :verify_authorized

  include ConditionsHelper

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
    @formatting     = export_params[:formatting] || @plan.settings(:export).formatting
    if params.key?(:phase_id)
      @selected_phase = @plan.phases.find(params[:phase_id])
    else
      @selected_phase = @plan.phases.order("phases.updated_at DESC")
                                    .detect { |p| p.visibility_allowed?(@plan) }
    end

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
    send_data render_to_string(partial: "shared/export/plan_txt"),
              filename: "#{file_name}.txt"
  end

  def show_docx
    # Using and optional locals_assign export_format
    render docx: "#{file_name}.docx",
           content: render_to_string(partial: "shared/export/plan",
             locals: { export_format: "docx" })
  end

  def show_pdf
    render pdf: file_name,
           margin: @formatting[:margin],
           footer: {
             center: _("Created using %{application_name}. Last modified %{date}") % {
               application_name: Rails.configuration.branding[:application][:name],
               date: l(@plan.updated_at.to_date, format: :readable)
              },
             font_size: 8,
             spacing:   (Integer(@formatting[:margin][:bottom]) / 2) - 4,
             right:     "[page] of [topage]",
             encoding: "utf8"
           }
  end

  def file_name
    # Sanitize bad characters and replace spaces with underscores
    ret = @plan.title
    Zaru.sanitize! ret
    ret = ret.strip.gsub(/\s+/, "_")
    # limit the filename length to 100 chars. Windows systems have a MAX_PATH allowance
    # of 255 characters, so this should provide enough of the title to allow the user
    # to understand which DMP it is and still allow for the file to be saved to a deeply
    # nested directory
    ret[0, 100]
  end

  def publicly_authorized?
    PublicPagePolicy.new(@plan, current_user).plan_organisationally_exportable? ||
      PublicPagePolicy.new(@plan).plan_export?
  end

  def privately_authorized?
    if current_user.present?
      PlanPolicy.new(current_user, @plan).export?
    else
      false
    end
  end

  def export_params
    params.fetch(:export, {})
  end

end
