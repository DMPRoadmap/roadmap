# frozen_string_literal: true

module Api

  module V1

    class PlanPolicy < ApplicationPolicy

      attr_reader :user, :plan

      def initialize(user, plan)
        @user = user
        @plan = plan
      end

      class Scope < Scope

        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
        # rubocop:disable Metrics/AbcSize
        def resolve
          ids = scope.publicly_visible.pluck(:id)
          if user.is_a?(ApiClient)
            ids += user.plans.pluck(:id)
          elsif user.is_a?(User)
            ids += user.org.plans.organisationally_visible.pluck(:id)
            ids += user.plans.pluck(:id)
            ids += user.org.plans.pluck(:id) if user.can_org_admin?
          end
          scope.where(id: ids.flatten.uniq)
        end
        # rubocop:enable Metrics/AbcSize

      end

      def index?
        user.present?
      end

      def show?
        user.present? && plan.present?
      end

      # rubocop:disable Metrics/AbcSize
      def create?
        return false unless user.present? && plan.present?
        # If the client is an ApiClient then they can create a Plan.
        # TODO: We may want to rethink this and perhaps restrict them in other ways
        return true if user.is_a?(ApiClient)

        # The client can only create the Plan if the plan is associated with
        # their Org or they are a contributor to the Plan
        plan.org == user.org || plan.contributors.collect(&:org).include?(user.org)
      end
      # rubocop:enable Metrics/AbcSize

    end

  end

end
