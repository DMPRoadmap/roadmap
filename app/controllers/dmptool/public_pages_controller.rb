# frozen_string_literal: true

module Dmptool
  # Customization to add the public facing 'Participating Institutions' page
  # rubocop:disable Metrics/ModuleLength
  module PublicPagesController
    # The publicly accessible list of participating institutions
    def orgs
      skip_authorization
      ids = ::Org.where.not(::Org.funder_condition).pluck(:id)
      @orgs = ::Org.participating.where(id: ids)
    end

    # Override of the core DMPRoadmap public plans method
    #
    # GET|POST /plans_index
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def plan_index
      selected_facets = process_facets
      search_term = process_search
      sort_by = process_sort_by

puts sort_by

      # Fetch the plan ids that match the user's search criteria
      #    NOTE: changing the order of columns in `pluck` will impact drop_unused_facets()
      plan_ids = ::Plan.joins(roles: [user: [:org]])
                       .publicly_visible
                       .search(search_term)
                       .faceted_search(facets: selected_facets, sort_by: sort_by)
                       .distinct
                       .pluck(%w[plans.id plans.title plans.funder_id plans.org_id plans.featured plans.created_at
                                 plans.language_id plans.research_domain_id].join(', '))

      # If the user clicked 'View All', set the per_page to match the record count
      per_page = plan_ids.length if public_plans_params[:all]
      per_page = public_plans_params.fetch(:per_page, 10) if per_page.blank?

      @viewing_all = public_plans_params[:all].present?

      # Handle pagination unless the user clicked 'View All' (Always do this last!)
      @paginated_plan_ids = Kaminari.paginate_array(plan_ids.map { |plan| plan[0] })
                                    .page(public_plans_params.fetch(:page, 1))
                                    .per(per_page)

      # Only do a full fetch of the plans that are on the current page!
      @plans = ::Plan.includes(:org, :funder, :language, :template, :research_domain, identifiers: [:identifier_scheme],
                                                                                      roles: [user: [:org]])
                     .joins(roles: [user: [:org]])
                     .publicly_visible
                     .where(::Role.creator_condition)
                     .where('roles.active = true')
                     .where('plans.id IN (?)', @paginated_plan_ids)
                     .order(sort_by)

      # Build the facets list and retain the user's current search, sort and faceting selections
      @facets = cached_facet_options
      build_facet(facet: :funders, ids: selected_facets[:funder_ids], plans: plan_ids, facet_pos_in_plans: 2)
      build_facet(facet: :institutions, ids: selected_facets[:org_ids], plans: plan_ids, facet_pos_in_plans: 3)
      build_facet(facet: :languages, ids: selected_facets[:lang_ids], plans: plan_ids, facet_pos_in_plans: 6)
      build_facet(facet: :subjects, ids: selected_facets[:sub_ids], plans: plan_ids, facet_pos_in_plans: 7)
      @facets = @facets.merge({ search: public_plans_params[:search], sort_by: public_plans_params[:sort_by] })
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    protected

    # Acceptable params for the public plans page
    def public_plans_params
      params.permit(:page, :per_page, :all, :sort_by, :search,
                    facet: [funder_ids: [], institution_ids: [], language_ids: [], subject_ids: []])
    end

    # Clean up the file name to make it OS friendly (removing newlines, and punctuation)
    def file_name(title)
      name = title.gsub(/[\r\n]/, ' ')
                  .gsub(/[^a-zA-Z\d\s]/, '')
                  .tr(' ', '_')

      name.length > 31 ? name[0..30] : name
    end

    # Select all of the facets the user has selected
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    def build_facet(facet:, ids:, plans:, facet_pos_in_plans:)
      return [] unless @facets[facet.to_sym].present?

      relevant_plan_ids = plans.map { |plan| plan[facet_pos_in_plans].to_s }

      # Only take the facets that apply to the current resultset!
      @facets[facet.to_sym] = @facets[facet.to_sym].select do |id, _hash|
        relevant_plan_ids.include?(id.to_s)
      end
      # Retain the user's selections and recalc the nbr_plans
      @facets[facet.to_sym].each do |id, hash|
        hash[:nbr_plans] = relevant_plan_ids.count(id)
        hash[:selected] = 'true' if ids.is_a?(Array) && ids.any? && ids.include?(id.to_s)
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity

    # Process the sort criteria
    def process_sort_by
      case public_plans_params.fetch(:sort_by, 'featured')
      when 'created_at'
        'plans.created_at desc'
      when 'title'
        'TRIM(plans.title) asc'
      else
        'plans.featured desc, plans.created_at desc'
      end
    end

    # Proces the search term
    def process_search
      public_plans_params[:search].present? ? "%#{public_plans_params[:search]}%" : '%'
    end

    # Process the facet selections
    def process_facets
      public_plans_params.fetch(:facet, {})
    end

    # Convert the results of the query into a Hash for our faceting section of the page
    def result_to_hash(array: [])
      hash = {}
      # Build the Hash for our faceting portion of the UI
      array.each do |item|
        next unless hash[item[0].to_s].nil?

        hash[item[0].to_s] = { label: item[1], nbr_plans: item[2], selected: 'false' }
      end
      hash
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
    def cached_facet_options
      # Stash all of the available faceting options into the cache so that its not using up valuable memory each time
      # {
      #   :funders=>
      #     [:"170", {:label=>"United States Department of Agriculture (usda.gov)", :nbr_plans=>18, :selected=>false}]
      #   ]
      #   :institutions=> [
      #     [:"4497", {:label=>"São Paulo Research Foundation (fapesp.br)", :nbr_plans=>313, :selected=>false}]
      #   ]
      #   :languages=> [
      #     [:"2", {:label=>"English (US)", :nbr_plans=>707, :selected=>false}
      #   ],
      #   :subjects=> [
      #     [:"6", {:label=>"Earth and related environmental sciences", :nbr_plans=>70, :selected=>false}
      #   ]
      # }
      # faceting_options = Rails.cache.fetch('public_plans/faceting_options', expires_in: 24.hours) do
      Rails.cache.fetch('public_plans/faceting_options', expires_in: 12.hours) do
        languages = ::Language.joins('INNER JOIN plans on plans.language_id = languages.id')
                              .where('plans.visibility = ?', ::Plan.visibilities[:publicly_visible])
                              .order('count(plans.id) DESC, languages.name')
                              .group('languages.id, languages.name')
                              .pluck('languages.id, languages.name, count(plans.id) as nbr_plans')

        funders = ::Org.joins(:funded_plans).includes(:funded_plans)
                       .where('plans.visibility = ?', ::Plan.visibilities[:publicly_visible])
                       .order('count(plans.id) DESC, orgs.name')
                       .group('orgs.id, orgs.name')
                       .pluck('orgs.id, orgs.name, count(plans.id) as nbr_plans')

        institutions = ::Org.joins(:plans).includes(:plans)
                            .where('plans.visibility = ?', ::Plan.visibilities[:publicly_visible])
                            .order('count(plans.id) DESC, orgs.name')
                            .group('orgs.id, orgs.name')
                            .pluck('orgs.id, orgs.name, count(plans.id) as nbr_plans')

        subjects = ::ResearchDomain.joins('INNER JOIN plans on plans.research_domain_id = research_domains.id')
                                   .where('plans.visibility = ?', ::Plan.visibilities[:publicly_visible])
                                   .order('count(plans.id) DESC, research_domains.label')
                                   .group('research_domains.id, research_domains.label')
                                   .pluck('research_domains.id, research_domains.label, count(plans.id) as nbr_plans')

        {
          funders: result_to_hash(array: funders),
          institutions: result_to_hash(array: institutions),
          languages: result_to_hash(array: languages),
          subjects: result_to_hash(array: subjects)
        }
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/BlockLength
  end
  # rubocop:enable Metrics/ModuleLength
end
