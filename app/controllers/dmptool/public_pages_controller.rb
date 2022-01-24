# frozen_string_literal: true

module Dmptool
  # Customization to add the public facing 'Participating Institutions' page
  module PublicPagesController

    # Override of the core DMPRoadmap public plans method
    #
    # GET /plans_index
    def plan_index
      @plans = ::Plan.includes(:org, :funder, :language, :template, :research_domain, roles: [:user])
                     .publicly_visible
                     .order(updated_at: :desc)

      @plan_count = @plans.length

      # Build the facets BEFORE pagination!
      funders = build_facet(association: :funder, association_attr: :name)
      orgs = build_facet(association: :org, association_attr: :name)
      languages = build_facet(association: :language, association_attr: :name)
      subjects = build_facet(association: :research_domain, association_attr: :label)

      @plans = @plans.limit(25)

      @facets = {
        funders: funders,
        institutions: orgs,
        languages: languages,
        subjects: subjects
      }
    end

    # The publicly accessible list of participating institutions
    def orgs
      skip_authorization
      ids = ::Org.where.not(::Org.funder_condition).pluck(:id)
      @orgs = ::Org.participating.where(id: ids)
    end

    protected

    # Clean up the file name to make it OS friendly (removing newlines, and punctuation)
    def file_name(title)
      name = title.gsub(/[\r\n]/, ' ')
                  .gsub(/[^a-zA-Z\d\s]/, '')
                  .gsub(/ /, '_')

      name.length > 31 ? name[0..30] : name
    end

    # Searches through the plans and builds a facet for the specified associated model
    # e.g. templates = build_facet(plans: @plans, association: :template, association_attr: :title)
    def build_facet(association:, association_attr:)
      facet = {}
      @plans.each do |plan|
        if plan.send(association.to_sym).present?
          hash = facet.fetch(:"#{plan.send(association.to_sym).id}", {
            label: plan.send(association.to_sym).send(association_attr.to_sym),
            nbr_plans: 0,
            selected: false
          })
          hash[:nbr_plans] += 1
          facet[:"#{plan.send(association.to_sym).id}"] = hash
        end
      end
      facet = facet.sort_by { |k, v| v[:nbr_plans] }.reverse
    end
  end
end
