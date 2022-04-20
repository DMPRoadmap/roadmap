# frozen_string_literal: true

module Api

  module V0
<<<<<<< HEAD

    class GuidanceGroupPolicy < ApplicationPolicy

      attr_reader :user, :guidance_group
=======
    # Security rules for API V0 Guidance Group endpoints
    class GuidanceGroupPolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is the guidance_group
>>>>>>> upstream/master

      def initialize(user, guidance_group)
        unless user.org.token_permission_types.include? TokenPermissionType::GUIDANCES
          raise Pundit::NotAuthorizedError, _('must have access to guidances api')
        end

<<<<<<< HEAD
        @user = user
        @guidance_group = guidance_group
=======
        super(user, guidance_group)
>>>>>>> upstream/master
      end

      ##
      # is the plan editable by the user
      def show?
        GuidanceGroup.can_view?(@user, @record)
      end

      ##
      # always allowed as index chooses which guidances to display
      def index?
        true
      end
    end

  end
<<<<<<< HEAD

=======
>>>>>>> upstream/master
end
