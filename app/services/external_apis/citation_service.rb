# frozen_string_literal: true

require 'bibtex'
require 'citeproc'
require 'csl/styles'

module ExternalApis

  # This service provides an interface to Datacite API.
  class CitationService < BaseService

    class << self

      def api_base_url
        Rails.configuration.x.datacite_citation&.api_base_url
      end

      def active
        Rails.configuration.x.datacite_citation&.active
      end

      # Create a new DOI
      # rubocop:disable Metrics/CyclomaticComplexity
      def fetch(id:)
        return nil unless active && id.present? && id.is_a?(RelatedIdentifier)

        resp = fetch_bibtex(uri: id_to_uri(id: id.value))
        return nil unless resp.present? && resp.code == 200

        bibtex = BibTeX.parse(resp.body)

        build_citation(work_type: id.work_type, bibtex: bibtex)
      rescue JSON::ParserError => e
        log_error(method: 'CitationService fetch JSON parse error', error: e)
        nil
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      private

      # Will convert 'doi:10.1234/abcdefg' to 'http://doi.org/10.1234/abcdefg'
      def id_to_uri(id:)
        return nil unless id.present?

        id.start_with?('http') ? id : "#{api_base_url}/#{id}"
      end

      # Recursively call the URI for application/x-bibtex
      def fetch_bibtex(uri:)
        return nil unless uri.present?

        # Cannot use underlying Base Service here because the Accept seems to
        # be lost after multiple redirects
        resp = HTTParty.get(uri, headers: { "Accept": "application/x-bibtex" },
                                 follow_redirects: false)
        return resp unless resp.headers["location"].present?

        fetch_bibtex(uri: resp.headers["Location"])
      end

      # Convert the BibTeX item to a citation
      def build_citation(work_type:, bibtex:)
        return nil unless work_type.present? && bibtex.data.first.id.present?

        cp = CiteProc::Processor.new(style: "chicago-author-date", format: "html")
        cp.import(bibtex.to_citeproc)
        citation = cp.render(:bibliography, id: bibtex.data.first.id)
        return nil unless citation.present? && citation.any?

        #citation = citation.first.gsub(/(“|“)#{bibtex.data.first.title.value}\.(”|”)/i) do |title|
        #  "#{title} [#{work_type.humanize}]."
        #end

        # The CiteProc renderer has trouble with some things so fix them here
        citation = citation.first.gsub(/{\\Textendash}/i, "-")
                                 .gsub("{", "").gsub("}", "")
                                 .gsub(/\.”\s+/, "\.” [#{work_type.humanize}]. ")

        citation.gsub(URI.regexp) do |url|
          if url.start_with?('http')
            "<a href=\"%{url}\" target=\"_blank\">%{url}</a>" % { url: url }
          else
            url
          end
        end
      end

    end

  end

end
