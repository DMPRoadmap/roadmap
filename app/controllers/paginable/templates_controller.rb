class Paginable::TemplatesController < ApplicationController
  include Paginable
  include TemplateFilter
      
  # GET /paginable/templates/all/:page  (AJAX)
  # -----------------------------------------------------
  def all
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).all?
    # Apply scoping
    hash = apply_scoping(params[:scope] || 'all', false, true)

    # Apply pagination
    hash[:templates] = hash[:templates].page(params[:page]) if params[:page] != 'ALL'
    
    # Gather up all of the publication dates for the live versions of each template.
    published = get_publication_dates(hash[:scopes][:dmptemplate_ids])
    
    paginable_renderise partial: 'all',
                        scope: hash[:templates],
                        locals: { current_org: current_user.org.id,
                                  customizations: hash[:customizations],
                                  published: published,
                                  scopes: hash[:scopes]}
  end
  
  # GET /paginable/templates/funders/:page  (AJAX)
  # -----------------------------------------------------
  def funders
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).funders?
    # Apply scoping
    hash = apply_scoping(params[:scope] || 'all', true, false)

    # Apply pagination
    hash[:templates] = hash[:templates].page(params[:page]) if params[:page] != 'ALL'
    
    # Gather up all of the publication dates for the live versions of each template.
    published = get_publication_dates(hash[:scopes][:dmptemplate_ids])
    
    paginable_renderise partial: 'funders',
                        scope: hash[:templates],
                        locals: { current_org: current_user.org.id,
                                  customizations: hash[:customizations],
                                  published: published,
                                  scopes: hash[:scopes] }
  end
  
  # GET /paginable/templates/orgs/:page  (AJAX)
  # -----------------------------------------------------
  def orgs
    raise Pundit::NotAuthorizedError unless Paginable::TemplatePolicy.new(current_user).orgs?
    # Apply scoping
    hash = apply_scoping(params[:scope] || 'all', false, false)
    
    # Apply pagination
    hash[:templates] = hash[:templates].page(params[:page]) if params[:page] != 'ALL'
    
    # Gather up all of the publication dates for the live versions of each template.
    published = get_publication_dates(hash[:scopes][:dmptemplate_ids])
    
    paginable_renderise partial: 'orgs',
                        scope: hash[:templates],
                        locals: { current_org: current_user.org.id,
                                  customizations: hash[:customizations],
                                  published: published,
                                  scopes: hash[:scopes]}
  end

  # GET /paginable/templates/publicly_visible/:page  (AJAX)
  # -----------------------------------------------------
  def publicly_visible
    template_ids = Template.families(Org.funder.pluck(:id)).publicly_visible.pluck(:dmptemplate_id) <<
    Template.where(is_default: true).valid.published.pluck(:dmptemplate_id)

    paginable_renderise(
      partial: 'publicly_visible',
      scope: Template.includes(:org).where(dmptemplate_id: template_ids.uniq.flatten).valid.published)
  end

  # GET /paginable/templates/:id/history/:page  (AJAX)
  # -----------------------------------------------------
  def history
    @template = Template.find(params[:id])
    authorize @template
    @templates = Template.where(dmptemplate_id: @template.dmptemplate_id)
    @current = Template.current(@template.dmptemplate_id)
    paginable_renderise(
      partial: 'history',
      scope: @templates,
      locals: { current: @current })
  end
end
