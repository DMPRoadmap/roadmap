# frozen_string_literal: true

module Api
<<<<<<< HEAD

  module V1

    class PlansPolicy < ApplicationPolicy

      attr_reader :client, :plan

      class Scope

        attr_reader :client, :scope

        def initialize(client, scope)
          @client = client
          @scope = scope
        end

=======
  module V1
    # Security rules for API V1 Plan endpoints
    class PlansPolicy < ApplicationPolicy
      # NOTE: @user is either a User or an ApiClient

      # A helper method that takes the current client and returns the plans they
      # have acess to
      class Scope
>>>>>>> upstream/master
        ## return the visible plans (via the API) to a given client
        # ALL can view: public
        # ApiClient can view: anything from the API client
        #                     anything belonging to their Org (if applicable)
        # User (non-admin) can view: any personal or organisationally_visible
        # User (admin) can view: all from users of their organisation
<<<<<<< HEAD
        # rubocop:disable Metrics/AbcSize
        def resolve
          ids = Plan.publicly_visible.pluck(:id)
          if client.is_a?(ApiClient)
            ids += client.plans.pluck(&:id)
            ids += client.org.plans.pluck(&:id) if client.org.present?
          elsif client.is_a?(User)
            ids += client.org.plans.organisationally_visible.pluck(:id)
            ids += client.plans.pluck(:id)
            ids += client.org.plans.pluck(:id) if client.can_org_admin?
          end
          Plan.where(id: ids.uniq)
        end
        # rubocop:enable Metrics/AbcSize

      end

      def initialize(client, plan)
        @client = client
        @plan = plan
      end

    end

  end

=======
        def resolve
          ids = @user.is_a?(ApiClient) ? plans_for_client : plans_for_user
          Plan.where(id: ids.uniq)
        end

        private

        def plans_for_client
          return [] unless @user.present?

          ids = @user.plans.pluck(&:id)
          ids += @user.org.plans.pluck(&:id) if @user.org.present?
          ids
        end

        def plans_for_user
          return [] unless @user.present?

          ids = @user.org.plans.organisationally_visible.pluck(:id)
          ids += @user.plans.pluck(:id)
          ids += @user.org.plans.pluck(:id) if @user.can_org_admin?
          ids
        end

        def initialize(client, plan)
          super()
          @user = client
          @plan = plan
        end
      end
    end
  end
>>>>>>> upstream/master
end
