# frozen_string_literal: true

module Dmptool
  # DMPTool specific helpers for Orgs
  class OrgPresenter
    include Rails.application.routes.url_helpers

    def initialize
      @shib = IdentifierScheme.by_name('shibboleth').first
    end

    def participating_orgs
      ::Org.participating.order(:name)
    end
  end
end
