# frozen_string_literal: true

require 'cgi'
module ExternalApis
  # This service provides an interface to the CrossRef API
  class CrossrefService < BaseService
    class << self
      def api_base_url
        Rails.configuration.x.crossref&.api_base_url || super
      end

      def active?
        Rails.configuration.x.crossref&.active || false
      end

      def execute_api_get(clean_doi)
        url = "#{api_base_url}/works/#{CGI.escape(clean_doi)}"
        headers = {
          # Add User-Agent for polite API Access
          # See https://www.crossref.org/documentation/retrieve-metadata/rest-api/access-and-authentication/ for more
          'User-Agent' => "DMPAssistant (mailto: #{Rails.configuration.x.organisation.development_email})",
          'Accept' => 'application/json'
        }
        HTTParty.get(
          url,
          headers: headers,
          open_timeout: 5,
          read_timeout: 5
        )
      end

      def parse_attributes(body, clean_doi)
        json = JSON.parse(body).with_indifferent_access
        work = json[:message]
        return nil if work.blank?

        # The `issued.date-parts` array from Crossref can be partial ([YYYY], [YYYY, MM], or [YYYY, MM, DD]).
        # We preserve the available precision only
        date_parts = work.dig(:issued, :'date-parts', 0) || []
        release_date = date_parts.compact.join('-') if date_parts.any?

        {
          title: work.dig(:title, 0),
          # Crossref uses 'abstract' for its description field
          description: ExternalApis::DoiResolutionService.sanitize_and_normalize_description(work[:abstract]),
          output_type: map_crossref_type(work[:type]),
          release_date: release_date,
          doi: clean_doi
        }
      end

      # Maps all Crossref work-types safely to ResearchOutput enum system
      # Run GET https://api.crossref.org/types to see all types
      def map_crossref_type(type)
        return :other if type.blank?

        case type.to_s.strip.downcase
        when 'dataset', 'database'
          :dataset
        when 'component'
          # Crossref uses 'component' to tag supplementary code snippets, software pieces,
          # and independent data files attached to publications.
          :software
        when 'journal-article', 'proceedings-article', 'report', 'report-component', 'report-series',
             'book', 'book-chapter', 'book-section', 'book-part', 'book-series', 'book-set',
             'edited-book', 'monograph', 'reference-book', 'reference-entry', 'dissertation',
             'posted-content', 'peer-review', 'journal', 'journal-volume', 'journal-issue',
             'proceedings', 'proceedings-series'
          :text
        else
          :other
        end
      end

      def log_and_notify_error(error, doi)
        # Local logs for immediate debugging
        Rails.logger.error "Crossref Service Error [fetch_metadata]: #{error.message}"
        # External error tracking to notify the team via Rollbar
        Rollbar.error(error, "Crossref Service Error [fetch_metadata] for DOI: #{doi}")
        nil
      end
    end
  end
end
