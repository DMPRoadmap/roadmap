# frozen_string_literal: true

# Simple proxy service that determines which DOI minter to use
class DoiService

  class << self

    # Retrieves a DOI for the specified plan. Note that the new Identifier is
    def mint_doi(plan:)
      # plan must exist and not already have a DOI
      return nil unless minting_service_defined? && plan.present? && plan.is_a?(Plan)
      return plan.doi if plan.doi.present?

      svc = minter
      return nil unless svc.present?

      doi = svc.mint_doi(plan: plan)
      return nil unless doi.present?

      doi = "#{svc.landing_page_url}#{doi}" unless doi.downcase.start_with?("http")
      Identifier.new(identifier_scheme: scheme(svc: svc),
                     identifiable: plan, value: doi)
    rescue StandardError => e
      Rails.logger.error "DoiService.mint_doi for Plan #{plan&.id} resulted in: #{e.message}"
      nil
    end

    def update_doi(plan:)
      # plan must exist and have a DOI
      return nil unless minting_service_defined? && plan.present? && plan.is_a?(Plan) && plan.doi.present?

      svc = minter
      return nil unless svc.present?

      doi = svc.update_doi(plan: plan)
      return nil unless doi.present?
    rescue StandardError => e
      Rails.logger.error "DoiService.update_doi for Plan #{plan&.id} resulted in: #{e.message}"
      nil
    end

    # Returns whether or not there is an active DOI minting service
    def minting_service_defined?
      Rails.configuration.x.allow_doi_minting && minter.present?
    end

    # Retrieves the identifier_scheme name for the active DOI minting service
    def scheme_name
      svc = minter
      return nil unless svc.present?

      scheme(svc: svc)&.name&.downcase
    end

    # Return the inheriting service's :callback_path (defined in their config)
    def scheme_callback_uri
      svc = minter
      return nil unless svc.present?

      svc.callback_path
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
