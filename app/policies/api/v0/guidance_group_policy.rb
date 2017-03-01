module Api
  module V0
    class GuidanceGroupPolicy < ApplicationPolicy
      attr_reader :user, :guidance_group

      def initialize(user, guidance_group)
        raise Pundit::NotAuthorizedError, _("must be logged in") unless user
        unless user.org.token_permission_types.include? TokenPermissionType::GUIDANCES
          raise Pundit::NotAuthorizedError, _("must have access to guidances api")
        end
        @user = user
        @guidance_group = guidance_group
      end

      ##
      # is the plan editable by the user
      def show?
        GuidanceGroup.can_view?(@user, @guidance_group)
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end

    end
  end
end