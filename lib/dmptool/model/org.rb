# frozen_string_literal: true

module Dmptool::Model::Org

  extend ActiveSupport::Concern

  class_methods do
    # DMPTool participating institution helpers
    def participating
      Org.includes(:identifier_schemes).where(is_other: false).order(:name)
    end
  end

  included do
    def shibbolized?
      org_identifiers.where(identifier_scheme: IdentifierScheme.find_by(name: "shibboleth")).present?
    end
  end

end