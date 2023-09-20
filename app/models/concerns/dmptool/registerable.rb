# frozen_string_literal: true

module Dmptool
  # Extensions that interact with the DMPHub system. Once a DMP ID has been registered, the DMPHub becomes the
  # source of ultimate authority for the DMP metadata.
  #
  # Note that ALL models that include this concern MUST implement a `complete?` method!
  #
  module Registerable
    extend ActiveSupport::Concern

    class_methods do
      # Determine if DMP ID registration has been enabled
      def registration_enabled?
        Rails.configuration.x.madmp.enable_dmp_id_registration
      end

      # Determine whether ORCID publication has been enabled and an IdentifierScheme has been defined
      def orcid_publication_enabled?
        Rails.configuration.x.madmp.enable_orcid_publication && !IdentifierScheme.where(name: 'orcid').first.nil?
      end
    end

    included do
      # Check if the Draft DMP has been registered with a DMP ID
      def registered?
        !dmp_id.blank?
      end

      # Returns whether or not minting is allowed for the current plan
      def dmp_id_registerable?
        return false unless self.class.registration_enabled?

        registerable?
      end

      # Returns whether or not minting is allowed for the current plan
      def orcid_publishable?
        return false unless self.class.orcid_publication_enabled?

        registerable?
      end

      # Return the citation for the DMP. For example:
      #     `Jane Doe. (2021). "My DMP" [Data Management Plan]. DMPTool. https://doi.org/10.12345/A1B2C3`
      #
      def citation
        return nil unless registerable?

        hash = latest_version
        return nil unless hash.is_a?(Hash) && hash['dmp'].present?

        hash = hash.fetch('dmp', {})
        authors = hash.fetch('contributor', []).map { |contrib| contrib['name'] }.join(', ')
        authors = hash.fetch('contact', {})['name'] unless authors.present?
        pub_year = Time.parse(hash.fetch('modified', hash['created']))&.strftime('%Y')
        app_name = ApplicationService.application_name
        "#{authors}. (#{pub_year}). \"#{hash['title']}\" [Data Management Plan]. #{app_name}. #{dmp_id}"
      end

      # Register a DMP ID for the object
      def register_dmp_id!(publish_to_orcid: false)
        # Just return the latest version if this one already has a registered DMP ID
        return latest_version if dmp_id.present? && dmp_id_registerable?

        # Call the DMPHub to register the DMP ID and upload the narrative PDF (performed async by ActiveJob)
        hash = DmpIdService.mint_dmp_id(plan: self)
        if hash.is_a?(Hash) && hash[:dmp_id].present?
            # Add the DMP ID to the Dmp record
          if update(dmp_id: hash[:dmp_id])
            publish_narrative!
            orcid = owner&.identifier_for_scheme(scheme: 'orcid') if publish_to_orcid
            # Only publish to ORCID if it is enabled and this is NOT development
            publish_to_orcid! if publish_to_orcid && orcid.present? && !Rails.env.development?

            latest_version
          else
            Rails.logger.error "Unable to save the DMP ID, '#{hash[:dmp_id].inspect}' for #{self.class.name}: #{id}"
            Rails.logger.error "Errors were: #{errors.full_messages}"
            nil
          end
        else
          Rails.logger.error "Unable to register a DMP ID at this time for Plan #{self.class.name}: #{id}"
          nil
        end
      end

      # Retrieve the latest version of the metadata from the local cache or the DMPHub
      def latest_version
        Rails.cache.fetch("dmp_ids/#{dmp_id}/latest", expires_in: 2.minutes) do
          DmpIdService.fetch_dmp_id(dmp_id: dmp_id)
        end
      end

      # Send the narrative PDF document to the DMPHub
      def publish_narrative!
        # Don't kick of the job if it is already enqueued!
        return false if self.respond_to?(:publisher_job_status) && self.publisher_job_status == 'enqueued'

        self.update(publisher_job_status: 'enqueued') if self.respond_to?(:publisher_job_status)
        PdfPublisherJob.set(wait: 2.minutes).perform_later(plan: self)
      rescue StandardError => e
        Rails.logger.error "Unable to publish PDF Narrative - #{e.message}"
      end

      # Upload the citation to the owner's ORCID record
      def publish_to_orcid!
        OrcidPublisherJob.set(wait: 5.minutes).perform_later(user: owner, plan: self) unless Rails.env.development?
      rescue StandardError => e
        Rails.logger.error "Unable to publish DMP ID to ORCID - #{e.message}"
      end
    end
  end
end
