module Api
  module V0
    class TemplatePolicy < ApplicationPolicy
      attr_reader :user, :template

      def initialize(user, template)
        raise Pundit::NotAuthorizedError, _("must be logged in") unless user
        unless user.org.token_permission_types.include? TokenPermissionType::TEMPLATES
          raise Pundit::NotAuthorizedError, _("must have access to guidances api")
        end
        @user = user
        @template = template
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end

    end
  end
end