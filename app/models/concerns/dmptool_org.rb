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
  end

end
