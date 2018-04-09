module TemplateFilter
  # Applies scoping to the template list
  def apply_scoping(scope, customizable = false, all = false)
    if customizable
      # Retrieve all of the publicly visible published funder templates
      orgs = Org.funder.where.not(id: current_user.org.id)
      # Include the default template in the list of funder templates
      orgs << Template.default.org unless current_user.org == Template.default.org

      templates = Template.get_public_published_template_versions(orgs)

      # If the user is an Org Admin look for customizations to funder templates
      customizations = {}
      if current_user.can_org_admin?
        family_ids = Template.families.pluck(:family_id)
        latest_customized_versions = Template.latest_customized_version(family_ids, current_user.org_id).includes(:org)
        customizations = latest_customized_versions.reduce({}) do |memo, customization|
          memo[customization.customization_of] = customization
          memo
        end
      end

      scopes = calculate_table_scopes(templates, customizations)

      # We scope based on the customizations
      if params[:scope].present? && params[:scope] != 'all'
        scoped = templates.select do |t| 
          c = customizations[t.family_id]
          (params[:scope] == 'unpublished' && (!c.present? || !c.published?)) || (params[:scope] == 'published' && c.present? && c.published?)
        end
        templates = Template.where(id: scoped.collect(&:id))
      end

    else
      # If we're collecting all templates
      if all
        templates = Template.latest_version_per_org(Org.all.pluck(:id)).includes(:org)
      else
        templates = Template.latest_version_per_org(Org.where(id: current_user.org.id)).includes(:org)
      end

      scopes = calculate_table_scopes(templates, {})

      if params[:scope].present? && params[:scope] != 'all'
        templates = templates.where(published: true) if params[:scope] == 'published'
        templates = templates.where(published: false) if params[:scope] == 'unpublished'
      end
    end

    { templates: templates,
      customizations: customizations || {},
      scopes: scopes }
  end

  private
    # Gets the nbr of templates and nbr of published/unpublished templates
    def calculate_table_scopes(templates, customizations)
      scopes = { all: templates.length, published: 0, unpublished: 0, family_ids: templates.collect(&:family_id).uniq }
      templates.each do |t|
        # If we have customizations use their status
        if customizations.keys.length > 0
          c = customizations[t.family_id]
          # If the template was not customized then its unpublished
          if c.nil?
            scopes[:unpublished] += 1
          else
            scopes[:published] += 1 if c.published?
            scopes[:unpublished] += 1 unless c.published?
          end
        else
          # Otherwise just use the template's published status
          scopes[:published] += 1 if t.published?
          scopes[:unpublished] += 1 unless t.published?
        end
      end
      scopes
    end

    def get_publication_dates(family_ids)
      published = {}
      lives = Template.live(family_ids)
      lives.each do |live|
        published[live.family_id] = live.updated_at
      end
      published
    end
end