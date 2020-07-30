# frozen_string_literal: true

# Simple proxy service that determines which DOI minter to use
class DoiService

  class << self

    # Retrieves a DOI for the specified plan. Note that the new Identifier is
    # rubocop:disable Metrics/AbcSize
    def mint_doi(plan:)
      # plan must exists and not already have a DOI
      return nil unless plan.present? && plan.is_a?(Plan)
      return plan.doi if plan.doi.present?

      svc = minter
      return nil unless svc.present?

      doi = svc.mint_doi(plan: plan)
      return nil unless doi.present?

      doi = "#{svc.landing_page_url}#{doi}" unless doi.downcase.start_with?("http")
      Identifier.new(identifier_scheme: scheme(svc: svc),
                     identifiable: plan, value: doi)
    end
    # rubocop:enable Metrics/AbcSize

    # Returns whether or not there is an active DOI minting service
    def minting_service_defined?
      minter.present?
    end

    # Retrieves the identifier_scheme name for the active DOI minting service
    def scheme_name
      svc = minter
      return nil unless svc.present?

      scheme(svc: svc)&.name&.downcase
    end

    private

    # Fetch the active DOI minting service
    def minter
      # Use Datacite if it has been activated
      return ExternalApis::DataciteService if ExternalApis::DataciteService.active?
      # Use the DMPHub if it has been activated
      return ExternalApis::DmphubService if ExternalApis::DmphubService.active?

      # Place additional DOI services here

      nil
    end

    # Retrieves or adds the DOI minting service's IdentifierScheme record
    def scheme(svc:)
      # Add the DOI service as an IdentifierScheme if it doesn't already exist
      scheme = IdentifierScheme.find_or_create_by(name: svc.name)
      if scheme.new_record?
        scheme.update(description: svc.description, active: true,
                      for_identification: true, for_plans: true)
      end
      scheme
    end

  end

end
