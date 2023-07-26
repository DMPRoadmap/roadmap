# frozen_string_literal: true

# Simple proxy service that determines which DMP ID minter to use
class DmpIdService
  class << self

    def fetch_dmp_id(dmp_id:)
      return nil unless dmp_id.present?

      svc = minter
      return nil if svc.blank? # || !minting_service_defined?

      svc.fetch_dmp_id(dmp_id: dmp_id)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.error "DmpIdService.fetch_dmp_id for DMP ID #{dmp_id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end

    def fetch_dmps(user:)
      return nil unless user.present?

      svc = minter
      return nil if svc.blank? # || !minting_service_defined?

      svc.fetch_dmps(user: user)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.error "DmpIdService.fetch_dmps for User #{user&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end

    # Registers a DMP ID for the specified plan.
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def mint_dmp_id(plan:, seeding: false)
      # plan must exist and not already have a DMP ID!
      return nil unless minting_service_defined? && (plan.is_a?(Plan) || plan.is_a?(Draft))
      return plan.dmp_id if plan.dmp_id.present? && !seeding

      svc = minter
      return nil if svc.blank? # || !minting_service_defined?

      dmp_id = svc.mint_dmp_id(plan: plan)
      return nil if dmp_id.blank?

      dmp_id = "#{svc.landing_page_url}#{dmp_id}" unless dmp_id.downcase.start_with?('http')
      Identifier.find_or_create_by(identifier_scheme: identifier_scheme, identifiable: plan, value: dmp_id)
    rescue StandardError => e
      Rails.logger.debug e.message
      Rails.logger.error "DmpIdService.mint_dmp_id for Plan #{plan&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Updates the DMP ID metadata
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def update_dmp_id(plan:)
      # plan must exist and have a DMP ID
      return nil unless minting_service_defined? && plan.present? && (plan.is_a?(Plan) || plan.is_a?(Draft)) &&
                        plan.dmp_id.present?

      svc = minter
      return nil if svc.blank?

      dmp_id = svc.update_dmp_id(plan: plan)
      return nil if dmp_id.blank?
    rescue StandardError => e
      Rails.logger.error "DmpIdService.update_dmp_id for #{plan&.class&.name} #{plan&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Updates the DMP ID metadata
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def delete_dmp_id(plan:)
      # plan must exist and have a DMP ID
      return nil unless minting_service_defined? && plan.present? && (plan.is_a?(Plan) || plan.is_a?(Draft)) &&
                        plan.dmp_id.present?

      svc = minter
      return nil if svc.blank?

      dmp_id = svc.delete_dmp_id(plan: plan)
      return nil if dmp_id.blank?
    rescue StandardError => e
      Rails.logger.error "DmpIdService.delete_dmp_id for Plan #{plan&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      nil
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    # Send the Plan's PDF to the DMP ID minting service
    def publish_pdf(plan:, pdf_file_name:)
      return false unless (plan.is_a?(Plan) || plan.is_a?(Draft)) && pdf_file_name.present?

      svc = minter
      return false if svc.blank?

      return svc.publish_pdf(plan: plan, pdf_file_name: pdf_file_name)
    rescue StandardError => e
      Rails.logger.error "DmpIdService.publish_pdf for Plan #{plan&.id} resulted in: #{e.message}"
      Rails.logger.error e.backtrace
      false
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
      scheme.update(description: svc.description, active: true, for_plans: true) if scheme.new_record?
      scheme
    end

    # Return the inheriting service's :callback_path (defined in their config)
    def scheme_callback_uri
      svc = minter
      return nil if svc.blank?

      svc.respond_to?(:callback_path) ? svc.callback_path : nil
    end

    # Return the inheriting service's :landing_page_url (defined in their config)
    def landing_page_url
      svc = minter
      return nil if svc.blank?

      svc.respond_to?(:landing_page_url) ? svc.landing_page_url : nil
    end

    # Return the inheriting service's :landing_page_url (defined in their config)
    def api_base_url
      svc = minter
      return nil if svc.blank?

      svc.respond_to?(:api_base_url) ? svc.api_base_url : nil
    end

    private

    # Fetch the active DMP ID minting service
    def minter
      # Warning!
      # *******************
      # If you need to change your DMP ID minting authority over time, you will need to
      # update the Plan.dmp_id method so that it is able to check all of the correct
      # identifier_schemes

      # Use Datacite if it has been activated
      return ExternalApis::DataciteService if ExternalApis::DataciteService.active?
      # Use the DMPHub if it has been activated
      return ExternalApis::DmphubService if ExternalApis::DmphubService.active?

      # Place additional DMP ID services here

      nil
    end
  end
end
