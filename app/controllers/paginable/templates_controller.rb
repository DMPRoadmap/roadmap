# frozen_string_literal: true

module Paginable
  # Controller for paginating/sorting/searching the templates tables
  class TemplatesController < ApplicationController
    include CustomizableTemplateLinkHelper
    include Paginable

    # TODO: Clean up this code for Rubocop

    # GET /paginable/templates/:page  (AJAX)
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def index
      authorize Template
      templates = Template.includes(:org).latest_version.where(customization_of: nil)
      case params[:f]
      when 'published'
        template_ids = templates.select { |t| t.published? || t.draft? }.collect(&:family_id)
        templates = Template.includes(:org).latest_version(template_ids).where(customization_of: nil)
      when 'unpublished'
        template_ids = templates.select { |t| !t.published? && !t.draft? }.collect(&:family_id)
        templates = Template.includes(:org).latest_version(template_ids).where(customization_of: nil)
      end
      paginable_renderise(
        partial: 'index',
        scope: templates,
        query_params: { sort_field: 'templates.title', sort_direction: :asc },
        locals: { action: 'index' },
        format: :json
      )
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # GET /paginable/templates/organisational/:page  (AJAX)
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def organisational
      authorize Template
      templates = Template.latest_version_per_org(current_user.org.id)
                          .where(customization_of: nil, org_id: current_user.org.id)
      case params[:f]
      when 'published'
        template_ids = templates.select { |t| t.published? || t.draft? }.collect(&:family_id)
        templates = Template.latest_version(template_ids)
      when 'unpublished'
        template_ids = templates.select { |t| !t.published? && !t.draft? }.collect(&:family_id)
        templates = Template.latest_version(template_ids)
      end
      paginable_renderise(
        partial: 'organisational',
        scope: templates,
        query_params: { sort_field: 'templates.title', sort_direction: :asc },
        locals: { action: 'organisational' },
        format: :json
      )
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # GET /paginable/templates/customisable/:page  (AJAX)
    # -----------------------------------------------------
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def customisable
      authorize Template
      customizations = Template.latest_customized_version_per_org(current_user.org.id)
      templates = Template.latest_customizable
      case params[:f]
      when 'published'
        customization_ids = customizations.select { |t| t.published? || t.draft? }.collect(&:customization_of)
        templates = Template.latest_customizable.where(family_id: customization_ids)
      when 'unpublished'
        customization_ids = customizations.select { |t| !t.published? && !t.draft? }.collect(&:customization_of)
        templates = Template.latest_customizable.where(family_id: customization_ids)
      when 'not-customised'
        templates = Template.latest_customizable.where.not(family_id: customizations.collect(&:customization_of))
      end
      paginable_renderise(
        partial: 'customisable',
        scope: templates.joins(:org).includes(:org),
        query_params: { sort_field: 'templates.title', sort_direction: :asc },
        locals: { action: 'customisable', customizations: customizations },
        format: :json
      )
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # GET /paginable/templates/publicly_visible/:page  (AJAX)
    # -----------------------------------------------------
    def publicly_visible
      # We want the pagination/sort/search to be retained in the URL so redirect instead
      # of processing this as a JSON
      paginable_params = params.permit(:page, :search, :sort_field, :sort_direction)
      redirect_to public_templates_path(paginable_params.to_h)
    end

    # GET /paginable/templates/:id/history/:page  (AJAX)
    # -----------------------------------------------------
    def history
      @template = Template.find(params[:id])
      authorize @template
      @templates = Template.where(family_id: @template.family_id)
      @current = Template.current(@template.family_id)
      paginable_renderise(
        partial: 'history',
        scope: @templates,
        query_params: { sort_field: 'templates.version', sort_direction: :desc },
        locals: { current: @templates.maximum(:version) },
        format: :json
      )
    end
  end
end
