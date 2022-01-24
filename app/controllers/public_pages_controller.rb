# frozen_string_literal: true

# Controller for the Public DMPs and Funder Requirements pages
class PublicPagesController < ApplicationController
  # --------------------------------
  # Start DMPTool Customization
  # --------------------------------
  include Dmptool::PublicPagesController
  # --------------------------------
  # End DMPTool Customization
  # --------------------------------

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
    unless PublicPagePolicy.new(@template).template_export?
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
      file_name = @template.title.gsub(/[^a-zA-Z\d\s]/, '').gsub(/ /, '_')
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
                   center: format(_('Template created using the %<application_name>s service. Last modified %<date>s'),
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
  #
  # DMPTool customizes this method
  #
  # def plan_index
  #   @plans = Plan.includes(:org, :funder, :language, :template, :research_domain, roles: [:user])
  #                .publicly_visible
  #                .order(updated_at: :desc)
  #
  #   @plan_count = @plans.length
  #
  #   @plans = @plans.limit(50)
  #
  #   render 'plan_index', locals: {
  #     faceting: {
  #       search_term: '',
  #       sort_by: '',
  #       page: 1,
  #       per_page: 10,
  #       funder_facet: @plans.select { |p| p.funder_id.present? }.map(&:funder).uniq,
  #       institution_facet: @plans.select { |p| p.org_id.present? }.map(&:org).uniq,
  #       language_facet: @plans.select { |p| p.language.present? }.map(&:language).uniq,
  #       subject_facet: @plans.select { |p| p.research_domain_id.present? }.map(&:research_domain).uniq
  #     }
  #   }
  # end

  private

  def paginable_params
    params.permit(:page, :search, :sort_field, :sort_direction)
  end

  def faceting_params
    params.permit(:faceting, :search_term, :sort_by, :page, :per_page,
                  funder_facet: [], institution_facet: [],
                  language_facet: [], subject_facet: [])
  end
end
