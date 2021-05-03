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
  class OrcidService < BaseDoiService

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
        Rails.configuration.x.orcid&.mint_path
      end

      def callback_path
        Rails.configuration.x.orcid&.callback_path
      end

      # Create a new DOI
      def add_work(user:, plan:)
        # Fail if this service is inactive or the plan does not have a DOI!
        return false unless active? && user.is_a?(User) && plan.is_a?(Plan) && plan.doi.present?

        orcid = user.identifier_for_scheme(scheme: name)
        token = ExternalApiAccessToken.for_user_and_service(user: user, service: name)

        # TODO: allow the user to reauth to get a token if they do not have one or theirs is expired/revoked

        # Fail if the user doesn't have an orcid or an acess token
        return false unless orcid.present? && token.present?

        target = api_base_url % { id: orcid.value.gsub(landing_page_url, "") }

        hdrs = {
          "Authorization": "Bearer #{token.access_token}",
          "Server-Agent": "#{ApplicationService.application_name} (#{Rails.application.credentials.orcid[:client_id]})"
        }

Rails.logger.warn xml_for(plan: plan, doi: plan.doi)

        resp = http_post(uri: target, additional_headers: hdrs, debug: true,
                         data: xml_for(plan: plan, doi: plan.doi))

        # DMPHub returns a 201 (created) when a new DOI has been minted or
        #                a 405 (method_not_allowed) when a DOI already exists
        unless resp.present? && [201, 405].include?(resp.code)
          handle_http_failure(method: "ORCID add work", http_response: resp)
          return false
        end

Rails.logger.warn "RESPONSE CODE: #{resp.code}"
Rails.logger.warn "HEADERS:"
Rails.logger.warn resp.headers
Rails.logger.warn "BODY:"
Rails.logger.warn resp.body

        add_subscription(plan: plan, put_code: resp.body) if resp.body.present?
        true
      end


      # Register the ApiClient behind the minter service as a Subscriber to the Plan
      # if the service has a callback URL and ApiClient
      def add_subscription(plan:, put_code:)
        return nil unless plan.is_a?(Plan) && put_code.present? && callback_path.present? &&
                          identifier_scheme.present?

        Subscription.create(
          plan: plan,
          subscriber: identifier_scheme,
          callback_uri: "#{api_base_url}#{callback_path % { put_code: put_code }}",
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
        Rails.cache.fetch("orcid_scheme", expires_in: 1.day) do
          IdentifierScheme.find_by("LOWER(name) = ?", name.downcase)
        end
      end

      def xml_for(plan:, doi:)
        return nil unless plan.is_a?(Plan) && doi.is_a?(Identifier)

        # Derived from:
        #  https://github.com/ORCID/orcid-model/blob/master/src/main/resources/record_3.0/samples/write_samples/work-full-3.0.xml
        #
        <<-XML
          <?xml version="1.0" encoding="UTF-8"?>
          <work:work xmlns:common="http://www.orcid.org/ns/common"
                     xmlns:work="http://www.orcid.org/ns/work"
                     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:schemaLocation="http://www.orcid.org/ns/work/work-3.0.xsd">
            <work:title>
              <common:title>#{plan.title}</common:title>
            </work:title>
            <work:short-description>#{plan.description}</work:short-description>
            <work:citation>
              <work:citation-type>formatted-unspecified</work:citation-type>
              <work:citation-value>#{plan.citation}</work:citation-value>
            </work:citation>
            <work:type>data-management-plan</work:type>
            <common:publication-date>
              <common:year>#{plan.created_at.strftime("%Y")}</common:year>
              <common:month>#{plan.created_at.strftime("%m")}</common:month>
              <common:day>#{plan.created_at.strftime("%d")}</common:day>
            </common:publication-date>
            <common:external-ids>
              <common:external-id>
                <common:external-id-type>doi</common:external-id-type>
                <common:external-id-value>#{doi.value_without_scheme_prefix}</common:external-id-value>
                <common:external-id-url>#{doi.value}</common:external-id-url>
                <common:external-id-relationship>self</common:external-id-relationship>
              </common:external-id>
            </common:external-ids>
            #{contributors_as_xml(authors: plan.owner_and_coowners)}
          </work:work>
        XML
      end

      def contributors_as_xml(authors:)
        return "" unless authors.is_a?(Array) && authors.any?

        ret = "<work:contributors>"

        authors.each do |author|
          orcid = author.identifier_for_scheme(scheme: name)
          ret += "<work:contributor>"
          if orcid.present?
            ret += <<-XML
              <common:contributor-orcid>
                <common:uri>#{orcid.value}</common:uri>
                <common:path>#{orcid.value_without_scheme_prefix}</common:path>
                <common:host>orcid.org</common:host>
              </common:contributor-orcid>
            XML
          end

          ret += <<-XML
              <work:credit-name>#{author.name(false)}</work:credit-name>
              <work:contributor-attributes>
                <work:contributor-role>author</work:contributor-role>
              </work:contributor-attributes>
            </work:contributor>
          XML
        end

        ret += "</work:contributors>"
      end

    end

  end

end
