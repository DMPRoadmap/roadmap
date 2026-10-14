# frozen_string_literal: true

module ExternalApis
  # This service calls DataCite and Crossref services accordingly when parsing DOIs
  class DoiResolutionService
    SERVICES = [
      [ExternalApis::DataciteService, 'datacite'],
      [ExternalApis::CrossrefService, 'crossref']
    ].freeze

    ALLOWED_TAGS = %w[p br strong em ul ol li blockquote a].freeze
    ALLOWED_ATTRIBUTES = %w[href title].freeze

    # Browser-compatible patterns shared with the client-side validation.
    MODERN_DOI_PATTERN = '10\.\d{4,9}/[-._;()/:A-Z0-9]+'
    OLD_DOI_PATTERN = '10\.1002/[^\s]+'

    # Matches ~99% of modern Crossref DOIs
    MODERN_DOI_REGEX = /\A#{MODERN_DOI_PATTERN}\z/i

    # Catch-all for early DOIs with complex/opaque formatting
    OLD_DOI_REGEX = /\A#{OLD_DOI_PATTERN}\z/i

    class << self
      def active?
        Rails.configuration.x.datacite&.active || Rails.configuration.x.crossref&.active
      end

      # Sanitizes and normalizes provider description markup server-side
      def sanitize_and_normalize_description(description)
        return nil if description.blank?

        normalized = normalize_jats(description)

        # Parse fragment and remove script/style tags along with their inner contents
        doc = Nokogiri::HTML::DocumentFragment.parse(normalized)
        doc.css('script, style').remove

        sanitized = ActionController::Base.helpers.sanitize(
          doc.to_html,
          tags: ALLOWED_TAGS,
          attributes: ALLOWED_ATTRIBUTES
        )

        sanitized&.strip
      end

      # Main function for the "Add Research Output by DOI" feature
      def fetch_metadata(doi:)
        return { status: :blank } if doi.blank?

        # Strip 'https://doi.org/'
        clean_doi = doi.strip.gsub(%r{^https?://doi.org/}, '')

        # Validate DOIs with regex
        # See https://www.crossref.org/blog/dois-and-matching-regular-expressions/ for more
        return { status: :invalid } unless clean_doi.match?(MODERN_DOI_REGEX) || clean_doi.match?(OLD_DOI_REGEX)

        # Check top-level metadata cache first to prevent duplicate resolutions
        cache_key = "doi_resolution/metadata/#{clean_doi.downcase}"
        cached_result = Rails.cache.read(cache_key)
        return cached_result if cached_result.present?

        resolve_from_providers(clean_doi, cache_key)
      end

      private

      def resolve_from_providers(clean_doi, cache_key)
        statuses = []

        # Check datacite first, fall back to crossref
        SERVICES.each do |service_module, service_name|
          res = execute_fetch(service_module, service_name, clean_doi)
          if res.is_a?(Hash)
            result = { status: :ok, metadata: res }
            Rails.cache.write(cache_key, result, expires_in: 5.minutes)
            return result
          end

          statuses << res
        end

        evaluate_statuses(statuses)
      end

      def evaluate_statuses(statuses)
        active_statuses = statuses.reject { |s| s == :inactive }

        if active_statuses.present? && active_statuses.all?(:not_found)
          { status: :not_found }
        else
          { status: :service_unavailable }
        end
      end

      def execute_fetch(service_module, service_name, clean_doi)
        return :inactive unless service_module.active?

        cache_key = "#{service_name}/metadata/#{clean_doi}"

        return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

        result = fetch_and_parse(service_module, clean_doi)
        Rails.cache.write(cache_key, result, expires_in: 5.minutes) if cacheable_result?(result)
        result
      rescue SocketError, HTTParty::Error, Timeout::Error, JSON::ParserError => e
        service_module.log_and_notify_error(e, clean_doi)
        :error
      end

      def fetch_and_parse(service_module, clean_doi)
        response = service_module.execute_api_get(clean_doi)
        case response&.code
        when 200
          service_module.parse_attributes(response.body, clean_doi) || :error
        when 404
          :not_found
        else
          :error
        end
      end

      def cacheable_result?(result)
        result.is_a?(Hash) || result == :not_found
      end

      def normalize_jats(text)
        string = text.dup
        # Replace JATS tags with equivalent standard HTML tags
        string.gsub!(/<jats:p(?:\s+[^>]*)?>/, '<p>')
        string.gsub!('</jats:p>', '</p>')
        string.gsub!(/<jats:italic(?:\s+[^>]*)?>/, '<em>')
        string.gsub!('</jats:italic>', '</em>')
        string.gsub!(/<jats:bold(?:\s+[^>]*)?>/, '<strong>')
        string.gsub!('</jats:bold>', '</strong>')
        string.gsub!(/<jats:list-item(?:\s+[^>]*)?>/, '<li>')
        string.gsub!('</jats:list-item>', '</li>')
        string.gsub!(/<jats:list(?:\s+[^>]*)?>/, '<ul>')
        string.gsub!('</jats:list>', '</ul>')
        string
      end
    end
  end
end
