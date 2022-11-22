# frozen_string_literal: true

module Dmptool
  # Customization to add the public facing 'Participating Institutions' page
  module PublicPagesController
    # Override of the core DMPRoadmap public plans method
    #
    # GET|POST /plans_index
    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def plan_index
      term = process_search
      @plans = ::Plan.includes(:org, :funder, :language, :template, :research_domain, roles: [:user])
                     .publicly_visible
                     .search(term)
                     .order(process_sort_by)

      # Build the facets/search/sort/pagination settings
      selections = public_plans_params.fetch(:facet, {})
      @facets = {
        search: public_plans_params.fetch(:search, ''),
        sort_by: public_plans_params.fetch(:sort_by, 'featured'),
        funders: build_facet(association: :funder, attr: :name,
                             selected: selections.fetch(:funder_ids, [])),
        institutions: build_facet(association: :org, attr: :name,
                                  selected: selections.fetch(:institution_ids, [])),
        languages: build_facet(association: :language, attr: :name,
                               selected: selections.fetch(:language_ids, [])),
        subjects: build_facet(association: :research_domain, attr: :label,
                              selected: selections.fetch(:subject_ids, []))
      }

      # Process any faceting
      process_facets

      # If the user clicked 'View All', set the per_page to match the record count
      per_page = @plans.length if public_plans_params[:all]
      per_page = public_plans_params.fetch(:per_page, 10) if per_page.blank?

      @viewing_all = public_plans_params[:all].present?

      # Handle pagination unless the user clicked 'View All' (Always do this last!)
      @plans = Kaminari.paginate_array(@plans)
                       .page(public_plans_params.fetch(:page, 1))
                       .per(per_page)
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # The publicly accessible list of participating institutions
    def orgs
      skip_authorization
      ids = ::Org.where.not(::Org.funder_condition).pluck(:id)
      @orgs = ::Org.participating.where(id: ids)
    end

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
                  .gsub(/ /, '_')

      name.length > 31 ? name[0..30] : name
    end

    # Searches through the plans and builds a facet for the specified associated model
    # e.g. templates = build_facet(plans: @plans, association: :template, attr: :title)
    # rubocop:disable Metrics/AbcSize
    def build_facet(association:, attr:, selected: [])
      facet = {}
      @plans.each do |plan|
        next if plan.send(association.to_sym).blank?

        hash = facet.fetch(:"#{plan.send(association.to_sym).id}", {
                             label: plan.send(association.to_sym).send(attr.to_sym),
                             nbr_plans: 0,
                             selected: selected.include?(plan.send(association.to_sym).id.to_s)
                           })
        hash[:nbr_plans] += 1
        facet[:"#{plan.send(association.to_sym).id}"] = hash
      end
      facet = facet.sort_by { |_k, v| v[:nbr_plans] }.reverse
    end
    # rubocop:enable Metrics/AbcSize

    # Process the sort criteria
    def process_sort_by
      case public_plans_params.fetch(:sort_by, 'featured')
      when 'created_at'
        'plans.created_at desc'
      when 'title'
        'plans.title asc'
      else
        'plans.featured desc, plans.created_at desc'
      end
    end

    # Proces the search term
    def process_search
      public_plans_params[:search].present? ? "%#{public_plans_params[:search]}%" : '%'
    end

    # Filter the plans by the selected facets
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def process_facets
      facets = public_plans_params.fetch(:facet, {})
      funder_ids = facets.fetch(:funder_ids, [])
      org_ids = facets.fetch(:institution_ids, [])
      lang_ids = facets.fetch(:language_ids, [])
      sub_ids = facets.fetch(:subject_ids, [])

      # Filter the results based on the selected facets
      @plans = @plans.select { |p| funder_ids.include?(p.funder_id.to_s) } if funder_ids.any?
      @plans = @plans.select { |p| org_ids.include?(p.org_id.to_s) } if org_ids.any?
      @plans = @plans.select { |p| lang_ids.include?(p.language_id.to_s) } if lang_ids.any?
      @plans = @plans.select { |p| sub_ids.include?(p.research_domain_id.to_s) } if sub_ids.any?
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
