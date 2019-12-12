# frozen_string_literal: true

class Paginable::TemplatesController < ApplicationController

  include CustomizableTemplateLinkHelper
  include Paginable

  # TODO: Clean up this code for Rubocop
  # rubocop:disable Metrics/LineLength

  # GET /paginable/templates/:page  (AJAX)
  # -----------------------------------------------------
  def index
    authorize Template
    templates = Template.latest_version.where(customization_of: nil)
    case params[:f]
    when "published"
      template_ids = templates.select { |t| t.published? || t.draft? }.collect(&:family_id)
      templates = Template.latest_version(template_ids).where(customization_of: nil)
    when "unpublished"
      template_ids = templates.select { |t| !t.published? && !t.draft? }.collect(&:family_id)
      templates = Template.latest_version(template_ids).where(customization_of: nil)
    end
    paginable_renderise(
      partial: "index",
      scope: templates.includes(:org),
      query_params: { sort_field: 'templates.title', sort_direction: :asc },
      locals: { action: "index" }
    )
  end

  # GET /paginable/templates/organisational/:page  (AJAX)
  # -----------------------------------------------------
  def organisational
    authorize Template
    templates = Template.latest_version_per_org(current_user.org.id)
                        .where(customization_of: nil, org_id: current_user.org.id)
    case params[:f]
    when "published"
      template_ids = templates.select { |t| t.published? || t.draft? }.collect(&:family_id)
      templates = Template.latest_version(template_ids)
    when "unpublished"
      template_ids = templates.select { |t| !t.published? && !t.draft? }.collect(&:family_id)
      templates = Template.latest_version(template_ids)
    end
    paginable_renderise(
      partial: "organisational",
      scope: templates,
      query_params: { sort_field: 'templates.title', sort_direction: :asc },
      locals: { action: "organisational" }
    )
  end

  # GET /paginable/templates/customisable/:page  (AJAX)
  # -----------------------------------------------------
  def customisable
    authorize Template
    customizations = Template.latest_customized_version_per_org(current_user.org.id)
    templates = Template.latest_customizable
    case params[:f]
    when "published"
      customization_ids = customizations.select { |t| t.published? || t.draft? }.collect(&:customization_of)
      templates = Template.latest_customizable.where(family_id: customization_ids)
    when "unpublished"
      customization_ids = customizations.select { |t| !t.published? && !t.draft? }.collect(&:customization_of)
      templates = Template.latest_customizable.where(family_id: customization_ids)
    when "not-customised"
      templates = Template.latest_customizable.where.not(family_id: customizations.collect(&:customization_of))
    end
    paginable_renderise(
      partial: "customisable",
      scope: templates.joins(:org).includes(:org),
      query_params: { sort_field: 'templates.title', sort_direction: :asc },
      locals: { action: "customisable", customizations: customizations }
    )
  end

  # rubocop:enable Metrics/LineLength

  # GET /paginable/templates/publicly_visible/:page  (AJAX)
  # -----------------------------------------------------
  def publicly_visible
    templates = Template.live(Template.families(Org.funder.pluck(:id)).pluck(:family_id))
                        .publicly_visible.pluck(:id) <<
      Template.where(is_default: true).unarchived.published.pluck(:id)
    paginable_renderise(
      partial: "publicly_visible",
      scope: Template.joins(:org)
                     .includes(:org)
                     .where(id: templates.uniq.flatten)
                     .published,
      query_params: { sort_field: 'templates.title', sort_direction: :asc }
    )
  end

  # GET /paginable/templates/:id/history/:page  (AJAX)
  # -----------------------------------------------------
  def history
    @template = Template.find(params[:id])
    authorize @template
    @templates = Template.where(family_id: @template.family_id)
    @current = Template.current(@template.family_id)
    paginable_renderise(
      partial: "history",
      scope: @templates,
      query_params: { sort_field: 'templates.title', sort_direction: :asc },
      locals: { current: @templates.maximum(:version) }
    )
  end

end
