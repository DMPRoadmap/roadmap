# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V0

    class DepartmentsPolicy < ApplicationPolicy

      attr_reader :user, :department

      def initialize(user, department)
        raise Pundit::NotAuthorizedError, _("must be logged in") unless user

        @user = user
        @department = department
      end
=======
  module V0
    # Security rules for API V0 Departments endpoints
    class DepartmentsPolicy < ApplicationPolicy
      # NOTE: @user is the signed_in_user and @record is an instance of Department
>>>>>>> upstream/master

      ##
      # an org-admin can create a department for their organisation
      def create?
        @user.can_org_admin?
      end

      ##
      # any user can view their organisation's list of departments
      def index?
        true
      end

      ##
      # an org-admin user can query for a list of users in each department
      def users?
        @user.can_org_admin?
      end

      ##
      # an org-admin may assign users (from their org) to a department (from their org)
      def assign_users?
        @user.can_org_admin? &&
<<<<<<< HEAD
          @department.present? &&
          @department.org == @user.org
=======
          @record.present? &&
          @record.org == @user.org
>>>>>>> upstream/master
      end

      ##
      # an org-admin may unassign users (from their org) from a department
      def unassign_users?
        @user.can_org_admin?
      end
<<<<<<< HEAD

    end

  end

=======
    end
  end
>>>>>>> upstream/master
end
