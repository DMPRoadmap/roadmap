class PublicPagesController < ApplicationController
  after_action :verify_authorized, except: [:template_index, :plan_index, :orgs, :get_started]

  def orgs
    funders = Org.funder.collect(&:id)
    render 'orgs', locals: { orgs: Org.participating.where.not(id: funders) }
  end
  def get_started
    render '/shared/dmptool/_get_started'
  end


  # GET template_index
  # -----------------------------------------------------
  def template_index
    templates = Template.live(Template.families(Org.funder.pluck(:id)).pluck(:family_id)).publicly_visible.pluck(:id) <<
    Template.where(is_default: true).unarchived.published.pluck(:id)
    @templates = Template.includes(:org).where(id: templates.uniq.flatten).unarchived.published.order(title: :asc).page(1)
  end

  # GET template_export/:id
  # -----------------------------------------------------
  def template_export
    # only export live templates, id passed is family_id
    @template = Template.live(params[:id])
    # covers authorization for this action.  Pundit dosent support passing objects into scoped policies
    raise Pundit::NotAuthorizedError unless PublicPagePolicy.new( @template).template_export?
    skip_authorization
    # now with prefetching (if guidance is added, prefetch annottaions/guidance)
    @template = Template.includes(:org, phases: {sections:{questions:[:question_options, :question_format, :annotations]}}).find(@template.id)
    @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]

    begin
      file_name = @template.title.gsub(/[^a-zA-Z\d\s]/, '').gsub(/ /, "_").gsub('/\n/', '').gsub('/\r/', '').gsub(':', '_')
      file_name = file_name[0..30] if file_name.length > 31
    
      respond_to do |format|
        format.docx { render docx: 'template_export', filename: "#{file_name}.docx" }
        format.pdf do
          render pdf: file_name,
          margin: @formatting[:margin],
          footer: {
            center:    _('Template created using the %{application_name} service. Last modified %{date}') % {application_name: Rails.configuration.branding[:application][:name], date: l(@template.updated_at.to_date, formats: :short)},
            font_size: 8,
            spacing:   (@formatting[:margin][:bottom] / 2) - 4,
            right:     '[page] of [topage]'
          }
        end
      end
    rescue ActiveRecord::RecordInvalid => e  # What scenario is this triggered in? it's common to our export pages
      #send back to public_index page
      redirect_to public_templates_path, alert: _('Unable to download the DMP Template at this time.')
    end

  end

  # GET plan_export/:id
  # -------------------------------------------------------------
  def plan_export
    @plan = Plan.includes(:answers).find(params[:id])
    # covers authorization for this action.  Pundit dosent support passing objects into scoped policies
    raise Pundit::NotAuthorizedError unless PublicPagePolicy.new(@plan, current_user).plan_organisationally_exportable? || PublicPagePolicy.new(@plan).plan_export?
    skip_authorization

    @show_coversheet = true
    @show_sections_questions = true
    @show_unanswered = true
    @public_plan = true

    @hash = @plan.as_pdf(@show_coversheet)
    @formatting = @plan.settings(:export).formatting
    file_name = @plan.title.gsub(/ /, "_").gsub('/\n/', '').gsub('/\r/', '').gsub(':', '_')
    file_name = file_name[0..30] if file_name.length > 31
    
    respond_to do |format|
      format.html
      format.csv  { send_data @exported_plan.as_csv(@sections, @unanswered_question, @question_headings),  filename: "#{file_name}.csv" }
      format.text { send_data @exported_plan.as_txt(@sections, @unanswered_question, @question_headings, @show_details),  filename: "#{file_name}.txt" }
      format.docx { render docx: 'export', filename: "#{file_name}.docx" }
      format.pdf do
        render pdf: file_name,
          margin: @formatting[:margin],
          footer: {
            center:    _('Created using the %{application_name} service. Last modified %{date}') % {application_name: Rails.configuration.branding[:application][:name], date: l(@plan.updated_at.to_date, formats: :short)},
            font_size: 8,
            spacing:   (@formatting[:margin][:bottom] / 2) - 4,
            right:     '[page] of [topage]'
          }
      end
    end
  end

  # GET /plans_index
  # ------------------------------------------------------------------------------------
  def plan_index
    @plans = Plan.publicly_visible.order(:title => :asc).page(1)
  end
end
