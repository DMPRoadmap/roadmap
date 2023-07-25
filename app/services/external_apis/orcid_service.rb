# frozen_string_literal: true

module ExternalApis
  # This service provides an interface to the ORCID member API:
  #   https://info.orcid.org/documentation/features/member-api/
  #   https://github.com/ORCID/ORCID-Source/tree/master/orcid-api-web
  #   https://github.com/ORCID/ORCID-Source/blob/master/orcid-api-web/tutorial/works.md
  #
  # It makes use of OAuth access tokens supplied by ORCID through the ORCID Omniauth gem for Devise.
  # The tokens are created when the user either signs in via ORCID, when the user links their account
  # on the Edit profile page or when the user tries to submit their DMP to ORCID but no valid token exists
  class OrcidService < BaseDmpIdService
    class << self
      # Retrieve the config settings from the initializer
      def landing_page_url
        Rails.configuration.x.orcid&.landing_page_url || super
      end

      def api_base_url
        Rails.configuration.x.orcid&.api_base_url || super
      end

      def active?
        Rails.configuration.x.orcid&.active || super
      end

      def name
        Rails.configuration.x.orcid&.name
      end

      def work_path
        Rails.configuration.x.orcid&.work_path
      end

      def callback_path
        Rails.configuration.x.orcid&.callback_path
      end

      # Create a new DOI
      # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def add_work(user:, plan:)
        # Fail if this service is inactive or the plan does not have a DOI!
        return false unless active? && user.is_a?(User) && plan.is_a?(Plan) && plan.dmp_id.present?

        orcid = user.identifier_for_scheme(scheme: name)
        token = ExternalApiAccessToken.for_user_and_service(user: user, service: name)

        # TODO: allow the user to reauth to get a token if they do not have one or theirs is expired/revoked

        # Fail if the user doesn't have an orcid or an acess token
        return false unless orcid.present? && token.present?

        target = "#{api_base_url}#{format(work_path, id: orcid.value.gsub(landing_page_url, ''))}"

        hdrs = {
          'Content-type': 'application/vnd.orcid+xml',
          Accept: 'application/xml',
          Authorization: "Bearer #{token.access_token}",
          'Server-Agent': "#{ApplicationService.application_name} (#{Rails.configuration.x.dmproadmap.orcid_client_id})"
        }

        resp = http_post(uri: target, additional_headers: hdrs, debug: true,
                         data: xml_for(plan: plan, dmp_id: plan.dmp_id, user: user))

        # ORCID returns a 201 (created) when the DMP has been added to the User's works
        #               a 405 (method_not_allowed) when the DMP is already in the User's works
        unless resp.present? && [201, 405].include?(resp.code)
          handle_http_failure(method: 'ORCID add work', http_response: resp)
          return false
        end

        add_subscription(plan: plan, callback_uri: resp.headers['location']) if resp.code == 201
        true
      end
      # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # Register the ApiClient behind the minter service as a Subscriber to the Plan
      # if the service has a callback URL and ApiClient
      def add_subscription(plan:, callback_uri:)
        return nil unless plan.is_a?(Plan) && callback_uri.present? && identifier_scheme.present?

        Subscription.create(
          plan: plan,
          subscriber: identifier_scheme,
          callback_uri: callback_uri,
          updates: true,
          deletions: true
        )
      end

      # Bump the last_notified timestamp on the subscription
      def update_subscription(plan:)
        return false unless plan.is_a?(Plan) && callback_path.present? && identifier_scheme.present?

        subscription = Subscription.find_by(plan: plan, subscriber: identifier_scheme)
        subscription.present? ? subscription.notify! : false
      end

      private

      def identifier_scheme
        Rails.cache.fetch('orcid_scheme', expires_in: 1.day) do
          IdentifierScheme.find_by('LOWER(name) = ?', name.downcase)
        end
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def xml_for(plan:, dmp_id:, user:)
        return nil unless plan.is_a?(Plan) && dmp_id.is_a?(Identifier) && user.is_a?(User)

        # Derived from:
        #  https://github.com/ORCID/orcid-model/blob/master/src/main/resources/record_3.0/samples/write_samples/work-full-3.0.xml
        #
        # Removed the following because ORCID sends a 400 Bad Request error with a complaint about the
        # Error: "The client application made a bad request to the ORCID API. Full validation error: unexpected
        #         element (uri:\"\", local:\"p\"). Expected elements are (none)"
        #
        # It works sometimes though
        #
        # <work:contributors>
        #   <work:contributor>
        #     <common:contributor-orcid>
        #       <common:uri>#{orcid.value}</common:uri>
        #       <common:path>#{orcid.value_without_scheme_prefix}</common:path>
        #       <common:host>orcid.org</common:host>
        #     </common:contributor-orcid>
        #     <work:credit-name>#{user.name(false)}</work:credit-name>
        #     <work:contributor-attributes>
        #       <work:contributor-role>author</work:contributor-role>
        #     </work:contributor-attributes>
        #   </work:contributor>
        # </work:contributors>
        <<-XML
          <work:work xmlns:common="http://www.orcid.org/ns/common"
                     xmlns:work="http://www.orcid.org/ns/work"
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:schemaLocation="http://www.orcid.org/ns/work/work-3.0.xsd">
            <work:title>
              <common:title>#{plan.title&.encode(xml: :text)}</common:title>
            </work:title>
            <work:short-description>#{plan.description&.encode(xml: :text)}</work:short-description>
            <work:citation>
              <work:citation-type>formatted-unspecified</work:citation-type>
              <work:citation-value>#{plan.citation&.encode(xml: :text)}</work:citation-value>
            </work:citation>
            <work:type>data-management-plan</work:type>
            <common:publication-date>
              <common:year>#{plan.created_at.strftime('%Y')}</common:year>
              <common:month>#{plan.created_at.strftime('%m')}</common:month>
              <common:day>#{plan.created_at.strftime('%d')}</common:day>
            </common:publication-date>
            <common:external-ids>
              <common:external-id>
                <common:external-id-type>doi</common:external-id-type>
                <common:external-id-value>#{dmp_id.value_without_scheme_prefix}</common:external-id-value>
                <common:external-id-url>#{dmp_id.value}</common:external-id-url>
                <common:external-id-relationship>self</common:external-id-relationship>
              </common:external-id>
            </common:external-ids>
          </work:work>
        XML
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
