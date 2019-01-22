# frozen_string_literal: true

module Dmptool

  module Model

    module Org

      extend ActiveSupport::Concern

      class_methods do
        # DMPTool participating institution helpers
        def participating
          self.includes(:identifier_schemes)
              .where(is_other: false)
        end
      end

      included do
        def shibbolized?
          shib = IdentifierScheme.find_by(name: "shibboleth")
          org_identifiers.where(identifier_scheme: shib).present?
        end
      end

    end

  end

end
