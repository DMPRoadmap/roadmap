# frozen_string_literal: true

module ExternalApis

  class ExternalApiError < StandardError; end

  class BaseService

    class << self

      # The following should be defined in each inheriting service's initializer.
      # For example:
      #   ExternalApis::RorService.setup do |config|
      #     config.x.ror.landing_page_url = "https://example.org/"
      #     config.x.ror.api_base_url = "https://api.example.org/"
      #   end
      def landing_page_url
        nil
      end

      def api_base_url
        nil
      end

      def max_pages
        5
      end

      def max_results_per_page
        50
      end

      def max_redirects
        3
      end

      def active
        false
      end

      # The standard headers to be used when communicating with an external API.
      # These headers can be overriden or added to when calling an external API
      # by sending your changes in the `additional_headers` attribute of
      # `http_get`
      def headers
        {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Accept-Encoding": "gzip",
          "Host": URI(api_base_url).hostname.to_s,
          "User-Agent": "#{app_name} (#{app_email})"
        }
      end

      # Logs the results of a failed HTTP response
      def handle_http_failure(method:, http_response:)
        content = http_response.inspect
        msg = "received a #{http_response&.code} response with: #{content}!"
        log_error(method: method, error: ExternalApiError.new(msg))
      end

      # Logs the specified error along with the full backtrace
      def log_error(method:, error:)
        return unless method.present? && error.present?

        Rails.logger.error "#{self.class.name}.#{method} #{error.message}"
        Rails.logger.error error.backtrace
      end

      private

      # Shortcut to the branding.yml
      def config
        Rails.configuration.branding
      end

      # Retrieves the application name from branding.yml or uses the App name
      def app_name
        config.fetch(:application, {}).fetch(:name, Rails.application.class.name)
      end

      # Retrieves the helpdesk email from branding.yml or uses the contact page url
      def app_email
        dflt = Rails.application.routes.url_helpers.contact_us_url
        config.fetch(:organisation, {}).fetch(:helpdesk_email, dflt)
      end

      # Makes a GET request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def http_get(uri:, additional_headers: {}, tries: 1)
        return nil unless uri.present?

        target, http = prep_http(target: uri)
        req = Net::HTTP::Get.new(target.request_uri)
        req = prep_headers(request: req, additional_headers: additional_headers)
        resp = http.request(req)
        # If we received a redirect then follow it as long as
        if resp.is_a?(Net::HTTPRedirection) && (tries < max_redirects)
          resp = http_get(uri: resp["location"], additional_headers: {},
                          tries: tries + 1)
        end
        resp
      rescue StandardError => e
        log_error(method: uri, error: e)
        nil
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      # Prepares the URI and a Net::HTTP object
      def prep_http(target:)
        return nil, nil unless target.present?

        uri = URI.parse(target)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == "https"
        [uri, http]
      end

      # Appends specified headers to the default headers and attaches them to
      # the specified Net::HTTP::[verb] object
      def prep_headers(request:, additional_headers: {})
        return nil unless request.present?

        headers.each { |k, v| request[k] = v }
        additional_headers.each { |k, v| request[k] = v }
        request
      end

    end

  end

end
