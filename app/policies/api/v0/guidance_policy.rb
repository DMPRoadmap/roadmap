# frozen_string_literal: true

module Api

  module V0
<<<<<<< HEAD

    class GuidancePolicy < ApplicationPolicy

      attr_reader :user
      attr_reader :guidance
=======
    # Security rules for API V0 Guidance endpoints
    class GuidancePolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is the guidance
>>>>>>> upstream/master

      def initialize(user, guidance)
        unless user.org.token_permission_types.include? TokenPermissionType::GUIDANCES
          raise Pundit::NotAuthorizedError, _('must have access to guidances api')
        end

<<<<<<< HEAD
        @user = user
        @guidance = guidance
=======
        super(user, guidance)
>>>>>>> upstream/master
      end

      ##
      # is the plan editable by the user
      def show?
        Guidance.can_view(@user, @record.id)
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
