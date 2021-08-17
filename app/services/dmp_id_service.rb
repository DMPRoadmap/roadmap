# frozen_string_literal: true

# Simple proxy service that determines which DMP ID minter to use
class DmpIdService

  class << self

    # Registers a DMP ID for the specified plan.
    def mint_dmp_id(plan:)

p "MINTER DEFINED? #{minting_service_defined?}"

      # plan must exist and not already have a DMP ID!
      return nil unless minting_service_defined? && plan.present? && plan.is_a?(Plan)
      return plan.dmp_id if plan.dmp_id.present?

      svc = minter

p svc.inspect

      return nil unless svc.present?

      dmp_id = svc.mint_dmp_id(plan: plan)

p "DMP_ID: #{dmp_id.inspect}"

      return nil unless dmp_id.present?

      dmp_id = "#{svc.landing_page_url}#{dmp_id}" unless dmp_id.downcase.start_with?("http")
      Identifier.new(identifier_scheme: scheme(svc: svc),
                     identifiable: plan, value: dmp_id)
    rescue StandardError => e
      Rails.logger.error "DmpIdService.mint_dmp_id for Plan #{plan&.id} resulted in: #{e.message}"
      nil
    end

    # Updates the DMP ID metadata
    def update_dmp_id(plan:)
      # plan must exist and have a DMP ID
      return nil unless minting_service_defined? && plan.present? && plan.is_a?(Plan) && plan.dmp_id.present?

      svc = minter
      return nil unless svc.present?

      dmp_id = svc.update_dmp_id(plan: plan)
      return nil unless dmp_id.present?
    rescue StandardError => e
      Rails.logger.error "DmpIdService.update_dmp_id for Plan #{plan&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end

    # Returns whether or not there is an active DMP ID minting service
    def minting_service_defined?
      Rails.configuration.x.madmp.enable_dmp_id_registration && minter.present? &&
        minter.api_base_url.present?
    end

    # Retrieves the corresponding IdentifierScheme associated with the
    def identifier_scheme
      svc = minter
      return nil unless svc.present? && svc.name.present?

      # Add the DMP ID service as an IdentifierScheme if it doesn't already exist
      scheme = IdentifierScheme.find_or_create_by(name: svc.name.downcase)
      if scheme.new_record?
        scheme.update(description: svc.description, active: true, for_plans: true)
      end
      scheme
    end

    # Return the inheriting service's :callback_path (defined in their config)
    def scheme_callback_uri
      svc = minter
      return nil unless svc.present?

      svc.respond_to?(:callback_path) ? svc.callback_path : nil
    end

    # Return the inheriting service's :landing_page_url (defined in their config)
    def landing_page_url
      svc = minter
      return nil unless svc.present?

      svc.respond_to?(:landing_page_url) ? svc.landing_page_url : nil
    end

    private

    # Fetch the active DMP ID minting service
    def minter
      # Use Datacite if it has been activated
      return ExternalApis::DataciteService if ExternalApis::DataciteService.active?
      # Use the DMPHub if it has been activated
      return ExternalApis::DmphubService if ExternalApis::DmphubService.active?

      # Place additional DMP ID services here

      nil
    end

  end

end
