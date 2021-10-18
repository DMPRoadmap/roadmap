# frozen_string_literal: true

module DmptoolOrg

  extend ActiveSupport::Concern

  included do
    # DMPTool participating institution helpers
    def self.participating
      includes(identifiers: :identifier_scheme).where(managed: true)
    end

    def shibbolized?
      managed? && identifier_for_scheme(scheme: "shibboleth").present?
    end

    class << self
      def initialize_from_org_autocomplete(name:)
        return nil unless name.present?

        org = Org.new(
          name: sign_up_params[:user_entered_name.humanize],
          contact_email: Rails.configuration.x.organisation.helpdesk_email,
          contact_name: _("%{app_name} helpdesk") % { app_name: ApplicationService.application_name },
          is_other: false,
          links: { "org": [{ "link": home_page, "text": "Home Page" }] },
          managed: false,
          institution: %w[college university].include?(name.downcase),
          organisation: !%w[college university].include?(name.downcase)
        )
        org.abbreviation = org.name_to_abbreviation
        org
      end
    end
  end

end
