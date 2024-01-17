# frozen_string_literal: true

require 'httparty'
require 'digest'
require 'zip'

module ExternalApis
  # Errors for External Api services
  class ExternalApiError < StandardError; end

  # Abstract service that provides HTTP methods for individual external api services
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

      def active?
        false
      end

      # The standard headers to be used when communicating with an external API.
      # These headers can be overriden or added to when calling an external API
      # by sending your changes in the `additional_headers` attribute of
      # `http_get`
      def headers
        hash = {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          'User-Agent': "#{app_name} (#{app_email})"
        }
        hash.merge({ Host: URI(api_base_url).hostname.to_s })
      rescue URI::InvalidURIError => e
        handle_uri_failure(method: "BaseService.headers #{e.message}",
                           uri: api_base_url)
        hash
      end

      # Logs the results of a failed HTTP response
      def handle_http_failure(method:, http_response:)
        content = http_response.inspect
        msg = "received a #{http_response&.code} response with: #{content}!"
        log_error(method: method, error: ExternalApiError.new(msg))
      end

      # Logs the results of a failed HTTP response
      def handle_uri_failure(method:, uri:)
        msg = "received an invalid uri: '#{uri&.to_s}'!"
        log_error(method: method, error: ExternalApiError.new(msg))
      end

      # Logs the specified error along with the full backtrace
      def log_error(method:, error:)
        return unless method.present? && error.present?

        Rails.logger.error "#{self.class.name}.#{method} #{error.message}"
        Rails.logger.error error.backtrace
      end

      # Logs the specified message (as INFO by default, WARN otherwise)
      def log_message(method:, message:, info: true)
        return unless method.present? && message.present?

        Rails.logger.send((info ? :info : :warn), "#{self.class.name}.#{method} #{message}")
      end

      # Emails the error and response to the administrators
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def notify_administrators(obj:, response: nil, error: nil)
        return false unless obj.present? && response.present?

        message = "#{obj.class.name} - #{obj.respond_to?(:id) ? obj.id : ''}"
        message += '<br>----------------------------------------<br><br>'

        message += "Sent: #{Rails.logger.debug(json_from_template(plan: obj))}" if obj.is_a?(Plan)
        message += "Sent: #{Rails.logger.debug(obj.to_json_for_registration)}" if obj.is_a?(Draft)
        message += '<br>----------------------------------------<br><br>' if obj.is_a?(Plan) || obj.is_a?(Draft)

        message += "#{name} received the following unexpected response:<br>"
        message += response.inspect.to_s
        message += '<br>----------------------------------------<br><br>'

        message += error.message if error.present? && error.is_a?(StandardError)
        message += error.backtrace || '' if error.present? && error.is_a?(StandardError)

        UserMailer.notify_administrators(message).deliver_now
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      # Retrieves the application name from dmproadmap.rb initializer or uses the App name
      def app_name
        ApplicationService.application_name
      end

      # Retrieves the helpdesk email from dmproadmap.rb initializer or uses the contact page url
      def app_email
        dflt = Rails.application.routes.url_helpers.contact_us_url || ''
        Rails.configuration.x.organisation.fetch(:helpdesk_email, dflt)
      end

      # Makes a GET request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_get(uri:, additional_headers: {}, debug: false)
        return nil if uri.blank?

        HTTParty.get(uri, options(additional_headers: additional_headers,
                                  debug: debug))
      rescue URI::InvalidURIError => e
        handle_uri_failure(method: "BaseService.http_get #{e.message}",
                           uri: uri)
        nil
      rescue HTTParty::Error => e
        handle_http_failure(method: "BaseService.http_get #{e.message}",
                            http_response: nil)
        nil
      end

      # Makes a PUT request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_put(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
        return nil if uri.blank?

        opts = options(additional_headers: additional_headers, debug: debug)
        opts[:body] = data
        opts[:basic_auth] = basic_auth if basic_auth.present?
        HTTParty.put(uri, opts)
      rescue URI::InvalidURIError => e
        handle_uri_failure(method: "BaseService.http_put #{e.message}", uri: uri)
        nil
      rescue HTTParty::Error => e
        handle_http_failure(method: "BaseService.http_put #{e.message}", http_response: nil)
        nil
      end

      # Makes a POST request to the specified uri with the additional headers.
      # Additional headers are combined with the base headers defined above.
      def http_post(uri:, additional_headers: {}, data: {}, basic_auth: nil, debug: false)
        return nil if uri.blank?

        opts = options(additional_headers: additional_headers, debug: debug)
        opts[:body] = data
        opts[:basic_auth] = basic_auth if basic_auth.present?
        HTTParty.post(uri, opts)
      rescue URI::InvalidURIError => e
        handle_uri_failure(method: "BaseService.http_post #{e.message}", uri: uri)
        nil
      rescue HTTParty::Error => e
        handle_http_failure(method: "BaseService.http_post #{e.message}", http_response: nil)
        nil
      end

      # Options for the HTTParty call
      def options(additional_headers: {}, debug: false)
        hash = {
          headers: headers.merge(additional_headers),
          follow_redirects: true,
          limit: 6
        }
        hash[:debug_output] = $stdout if debug
        hash
      end

      # Unzips the specified file
      def unzip_file(zip_file:, destination:)
        return false unless zip_file.present? && File.exist?(zip_file)

        Zip::File.open(zip_file) do |files|
          files.each do |entry|
            next if File.exist?(entry.name)

            f_path = File.join(destination, entry.name)
            FileUtils.mkdir_p(File.dirname(f_path))
            files.extract(entry, f_path) unless File.exist?(f_path)
          end
        end
        true
      end

      # Determine if the downloaded file matches the expected checksum
      def validate_downloaded_file(file_path:, checksum:)
        return false unless file_path.present? && checksum.present? && File.exist?(file_path)

        possible_checksums = [
          Digest::SHA1.file(file_path).to_s,
          Digest::SHA256.file(file_path).to_s,
          Digest::SHA512.file(file_path).to_s,
          Digest::MD5.file(file_path).to_s
        ]
        possible_checksums.include?(checksum)
      end
    end
  end
end
