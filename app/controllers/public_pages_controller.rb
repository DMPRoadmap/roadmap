# frozen_string_literal: true

# Controller for the Public DMPs and Funder Requirements pages
class PublicPagesController < ApplicationController
  # GET template_index
  # -----------------------------------------------------
  # rubocop:disable Metrics/AbcSize
  def template_index
    @templates_query_params = {
      page: paginable_params.fetch(:page, 1),
      search: paginable_params.fetch(:search, ''),
      sort_field: paginable_params.fetch(:sort_field, 'templates.title'),
      sort_direction: paginable_params.fetch(:sort_direction, 'asc')
    }

    templates = Template.live(Template.families(Org.funder.pluck(:id)).pluck(:family_id))
                        .publicly_visible.pluck(:id) <<
                Template.where(is_default: true).unarchived.published.pluck(:id)
    @templates = Template.includes(:org)
                         .where(id: templates.uniq.flatten)
                         .unarchived.published
  end
  # rubocop:enable Metrics/AbcSize

  # GET template_export/:id
  # -----------------------------------------------------
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def template_export
    # only export live templates, id passed is family_id
    @template = Template.live(params[:id])
    # covers authorization for this action.
    # Pundit dosent support passing objects into scoped policies
    unless PublicPagePolicy.new(current_user, @template).template_export?
      msg = 'You are not authorized to export that template'
      redirect_to public_templates_path, notice: msg and return
      # raise Pundit::NotAuthorizedError
    end

    # now with prefetching (if guidance is added, prefetch annottaions/guidance)
    @template = Template.includes(
      :org,
      phases: {
        sections: {
          questions: %i[
            question_options
            question_format
            annotations
          ]
        }
      }
    ).find(@template.id)
    @formatting = Settings::Template::DEFAULT_SETTINGS[:formatting]

    begin
      file_name = @template.title.gsub(/[^a-zA-Z\d\s]/, '').tr(' ', '_')
      file_name = "#{file_name}_v#{@template.version}"
      respond_to do |format|
        format.docx do
          render docx: 'template_exports/template_export', filename: "#{file_name}.docx"
        end

        format.pdf do
          render pdf: file_name,
                 template: 'template_exports/template_export',
                 margin: @formatting[:margin],
                 footer: {
                   center: format(_('Template created using the %{application_name} service. Last modified %{date}'),
                                  application_name: ApplicationService.application_name,
                                  date: l(@template.updated_at.to_date, formats: :short)),
                   font_size: 8,
                   spacing: (@formatting[:margin][:bottom] / 2) - 4,
                   right: '[page] of [topage]',
                   encoding: 'utf8'
                 }
        end
      end
    rescue ActiveRecord::RecordInvalid
      # What scenario is this triggered in? it's common to our export pages
      redirect_to public_templates_path,
                  alert: _('Unable to download the DMP Template at this time.')
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # GET /plans_index
  # ------------------------------------------------------------------------------------
  def plan_index
    @plans = Plan.publicly_visible.includes(:template)
    render 'plan_index', locals: {
      query_params: {
        page: paginable_params.fetch(:page, 1),
        search: paginable_params.fetch(:search, ''),
        sort_field: paginable_params.fetch(:sort_field, 'plans.updated_at'),
        sort_direction: paginable_params.fetch(:sort_direction, 'desc')
      }
    }
  end

  private

  def paginable_params
    params.permit(:page, :search, :sort_field, :sort_direction)
  end
end
