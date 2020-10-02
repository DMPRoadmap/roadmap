# frozen_string_literal: true

module Dmptool

  class OrgPresenter

    include Rails.application.routes.url_helpers

    def initialize
      @shib = IdentifierScheme.by_name("shibboleth").first
    end

    def participating_orgs
      Org.participating.order(:name)
    end

    def sign_in_url(org:)
      return nil unless org.present? && @shib.present?

      "#{shibboleth_ds_path}/#{org.id}"
    end

  end

end
