# frozen_string_literal: true

module Api
  module V0
    # Security rules for API V0 Template endpoints
    class TemplatePolicy < ApplicationPolicy
      def initialize(user, template)
        unless user.org.token_permission_types.include? TokenPermissionType::TEMPLATES
          raise Pundit::NotAuthorizedError, _('must have access to templates api')
        end

        super
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end
    end
  end
end
