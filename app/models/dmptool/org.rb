# frozen_string_literal: true

module Models

  module Dmptool

    module Org

      extend ActiveSupport::Concern

      class_methods do
        # DMPTool participating institution helpers
        def participating
          includes(identifiers: :identifier_scheme).where(managed: true)
        end
      end

      included do
        def shibbolized?
          managed? && identifier_for_scheme(scheme: "shibboleth").present?
        end
      end

    end

  end

end
